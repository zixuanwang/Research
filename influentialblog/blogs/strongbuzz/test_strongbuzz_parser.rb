require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'
#encoding: utf-8
begin
  require 'system_timer'
  MyTimer = SystemTimer
rescue LoadError
  require 'timeout'
  MyTimer = Timeout
end

Hpricot.buffer_size = 262144
@TEST = 0

class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",                                                  
                                  :host => "pierce.rutgers.edu",
                                  :username => "root",                                                  
                                  :password => "",
                                  :database => "Weblog")

module Normalize
def normalize_url(text)
  url_char = {
  '%20' => ' ',
  '%2F' => '/',
  '%3A' => ':',
  '%3F' => '?'
  }

  url_char.each do |key, value|
    text.gsub!(key,value)
  end
end

def normalize_text(text)
 unicode_ansc = {
  '&#8211;' => '-',
  '&#8212;' => '--',
  '&#8220;' => '"',
  '&#8221;' => '"',
  '&#8216;' => '\'',
  '&#8217;' => '\'',
  '&#8230;' => '...',
  '&#183;'  => '.',
  '&#161;' => 'i',
  '&#168;'  => '"',
  '&#180;'  => '\'',
  '&#151;'  => '--',
  '&#150;'  => '-',
  '&#x00ab;'=> '<<',
  '&#x00bb;'=> '>>',
  '&raquo;' => '>>',
  '&rsquo;'=>'\'',
  '&lsquo;' => '\'',
  '&laquo;' => '<<',
  '&ldquo;' => '"',
  '&rdquo;' => '"',
  '&mdash;' =>'-',
  '&middot' => '|',
  '&nbsp;' => ' ',
  '&#148;' => '"',
  '&euml;'=>'e',
  '&Emul;'=>'E',
  '&#063;' => '?',
  '&#038;' => '&',
  '&#x00bb;'=>'',
  '&#39;' => '\''
 }

 unicode_ansc.each do |key, value|
   text.gsub!(key, value)
 end
end
end #end of module

#Here is the use of the Abstract Factory pattern
def blogparser_pipeline(factory)
  new_site = factory.new
  if @TEST == 1 
    new_site.test_main
  else
    new_site.main
  end
 
  puts "created a new  #{new_site.class} with a factory"
end

class Strongbuzz 
  include Normalize
  def parse(in_url,log)
    url = in_url.strip
    doc = nil
    badurls = File.open("badurls","a+")
    begin
      MyTimer::timeout(30) do 
      fullpage = Hpricot(open(in_url)).to_s
      normalize_text(fullpage)
      doc = Hpricot(fullpage)
      end
    rescue MyTimer::Error => timeout
      puts "Timeout"
      badurls.puts(in_url)
      badurls.close
      return
    rescue Exception => e
      badurls.puts(in_url)
      puts "open url #{e}"
      badurls.close
      return
    end
    #get title
    t = doc.at("//div[@class='center-column-content']/p[@class='post-title']")
    if t.nil?
      puts "Can't find title"
    else
      tt=t.inner_text.strip
      if tt =~ /^"(.*)"$/
        title = $1.strip
        title = title.gsub("\"","\\\"")
      else
        title = tt.gsub("\"","\\\"")
      end
    end
    title.force_encoding('utf-8')
    #get date
    d = doc.at("//div[@class='center-column-content']/span.post-date-time")
    if d.nil?
      puts "Can't find date"
    else
      dd = d.inner_text.strip
      if dd =~ /Posted:(.*)/
        ddd = $1.strip
      else
        puts "Can't parse date"
      end
    end
    if ddd.empty? or ddd.nil?
      puts "no date??"
    else
      date = Time.parse(ddd).strftime("%Y-%m-%d %H:%M:%S")
    end
    
    #get author
    author = "andrea strong "
  
    #get content
    content = ""
    doc.search("div.center-column-content/p.post-title").remove
    doc.search("div.center-column-content/p.postmeta").remove
    doc.search("div.center-column-content/table").remove
    doc.search("div.center-column-content/h2").remove
    cdiv = doc.at("//div.center-column-content")
    if cdiv.nil?
      puts "Can't find content"
    else
        begin  
          content=cdiv.inner_text.strip
        rescue Encoding::CompatibilityError => encoding
          puts "drop para, #{encoding}"
        end
    end #endof cdiv.nil?
    content = content.gsub(/\\/,"").gsub(/\s+/," ").gsub("\"","\\\"")
    #get links
    linkarray = Array.new
    (cdiv/"//p//a").each do |each_link|
      if each_link.attributes['href'].nil?
        puts "Empty href"
      else
        linkarray << each_link.attributes['href']
      end
    end
    
    #get comments
    
    commentarray=Array.new
    doc.search("//div[@class='center-column-content last']/div.comment-box").each do|each_c|
      commentHash=Hash.new
      ca = each_c.at("/div.screen-name/a")
      if ca.nil?
        puts "Can't find comment's author"
      else
        commentHash['author']=ca.inner_text.strip
      end
      cd = each_c.at("/div.screen-name/span.post-date-time")
      if cd.nil?
        puts "Can't find comment timestamp"
      else
        commentHash['date']=Time.parse(cd.inner_text.strip).strftime("%Y-%m-%d %H:%M:%S")
      end
      cc = each_c.at("/div.comment-text")
      if cc.nil?
        puts "Can't find comment content"
      else
        commentHash['content']=cc.inner_text.strip.gsub(/\\/,"").gsub("\"","\\\"").gsub(/\s+/," ")
      end
     commentarray<<commentHash if !commentHash.empty?     
    end#end of each comments
    
   log.puts("***URL", url, "***TITLE", title, "***AUTHOR", author,"***DATE", date)
   log.puts("***CONTENT", content)
   log.puts("***LINKS: #{linkarray.size}")
   linkarray.uniq.each do |l|
    log.puts l
   end
   log.puts("***COMMENTS: #{commentarray.size}")
   commentarray.each do |c|
     log.puts(c['author'])
     log.puts(c['date'])
     log.puts(c['content'])
   end
  
  site_id=22
  sql =<<-SQL
      select blog_id from blogs where blog_url = "#{url}"
   SQL
   blog_exist = DBConnection::connection.select_all(sql)
   blog_id = 0
    
   if blog_exist.empty?
     puts("insert into db: #{url}")
     sql = <<-SQL
       insert into blogs (site_id, blog_id,blog_url,publish_date, author_name,content, title) 
       values ("#{site_id}",null,"#{url}","#{date}","#{author}","#{content}","#{title}")
      SQL
    DBConnection::connection.execute(sql)
    sql = <<-SQL
      select blog_id from blogs where blog_url = "#{url}"
    SQL
    blog_id = DBConnection::connection.select_all(sql)[0]["blog_id"]
    else
      blog_id = DBConnection::connection.select_all(sql)[0]["blog_id"]
    end # end of if blog doesn't exist
    puts blog_id 
     
    linkarray.uniq.each do |each_link|
      if  each_link =~ /([^"]+)"(.*)/
        each_link = $1
      end
      if each_link =~ /^https?:\/\/([^\/]*)\/(.*)/
          l_domain = $1
          sql =<<-SQL
            select id from link_info where link_url = "#{each_link}"
          SQL
          link_exist = DBConnection::connection.select_all(sql)

          link_id = 0
          if link_exist.empty?
            sql=<<-SQL
              insert into link_info(link_url, link_domain)
              values("#{each_link}","#{l_domain}")
            SQL
            DBConnection::connection.execute(sql)
            sql=<<-SQL
              select id from link_info where link_url = "#{each_link}"
            SQL
            link_id = DBConnection::connection.select_all(sql)[0]['id']
          else
            link_id = DBConnection::connection.select_all(sql)[0]['id']
          end  
          
          sql=<<-SQL
            select id from blog_links where link_id = #{link_id} and blog_id = #{blog_id}
          SQL
          dup = DBConnection::connection.select_all(sql)
          if dup.empty?
            sql=<<-SQL
              insert into blog_links(blog_id,link_id)
              values("#{blog_id}", "#{link_id}")
            SQL
            DBConnection::connection.execute(sql)
            sql =<<-SQL
              insert into outlinks(blog_id, link_id, link, link_domain)
              values("#{blog_id}",null, "#{each_link}","#{l_domain}")
            SQL
            DBConnection::connection.execute(sql)
          end #end if dup.empty
          l_domain=""
      end # end of if link = http://
    end # end of links.each
   commentarray.each do |each_c|
      sql=<<-SQL
        select comment_id from comments where blog_id = #{blog_id}
          and author_name = "#{each_c['author']}" and publish_date = "#{each_c['date']}"
          and content = "#{each_c['content']}"
      SQL
     comment_exist = DBConnection::connection.select_all(sql) 
     if comment_exist.empty?
        sql=<<-SQL
          insert into comments(blog_id, comment_id, author_name,publish_date,content)
          values("#{blog_id}",null,"#{each_c['author']}","#{each_c['date']}","#{each_c['content']}")
        SQL
        DBConnection::connection.execute(sql)
     end
    end # end of commentarray.each
 end # end of parse function
def test_main
  test_url = "http://thestrongbuzz.com/buzz/details.php?item_id=217&title=The_Strong_Buzz_for_August_20th:_Dining_for_Darfur_is_Tomorrow,_Lots_of_News,_Events,_My_Dinner_at_Z"
  log_file = File.open("testlog","a+")
  parse(test_url, log_file)
  log_file.close
end #end of test main

def main
  log_file=File.open("strongbuzz.log","a+")
  urls =File.open("urls","r+")
#  urls =File.open("contineurl","r+")
  while url=urls.gets
    puts url.chomp
    parse(url.chomp, log_file)
  end#end of while
  log_file.close
  urls.close
end #end of main

end #end of class

blogparser_pipeline(Strongbuzz)
