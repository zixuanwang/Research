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
#@TEST = 1

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
  '&#8243;' =>'"',
  '&#187;'  => '>>',
  '&#183;'  => '.',
  '&#39;'   =>'\'',
  '&#161;'  => 'i',
  '&#176;'  => '',
  '&#333;'  => 'o',
  '&#252;'  => 'u',
  '&#233;'  => 'e',
  '&#231;'  => 'c',
  '&#232;'  => 'e',
  '&#224;'  => 'a',
  '&#235;'  => 'e',
  '&#0160;' => ' ',
  '&#168;'  => '"',
  '&#180;'  => '\'',
  '&#151;'  => '--',
  '&#150;'  => '-',
  '&#x00ab;'=> '<<',
  '&#x00bb;'=> '>>',
  '&raquo;' => '>>',
  '&rsquo;' =>'\'',
  '&lsquo;' => '\'',
  '&laquo;' => '<<',
  '&ldquo;' => '"',
  '&rdquo;' => '"',
  '&mdash;' =>'-',
  '&ndash;' => '-',
  '&middot' => '|',
  '&nbsp;' => ' ',
  '&#148;' => '"',
  '&euml;'=>'e',
  '&Emul;'=>'E',
  '&ecirc;'=>'e',
  '&eacute;'=>'e',
  '&#063;' => '?',
  '&#038;' => '&',
  '&#x00bb;'=>'',
  '&#39;' => '\'',
  '&amp;' => '&',
  '&cent;' =>'cent',
  '&deg;'=>'degree',
  '&trade;'=>'TM',
  '&copy;' =>'',
  '&ntilde;'=>'n',
  '&lt;'=>'<',
  '&gt;'=>'>'
 }

 unicode_ansc.each do |key, value|
   text.gsub!(key, value)
 end
end #end of function
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

class Restaurantgirl 
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
      puts "#{timeout}"
      badurls.puts("#{timeout}: #{in_url}")
      badurls.close
      return
    rescue Exception => e
      badurls.puts("#{e}: #{in_url}")
      puts "When open url #{e}"
      badurls.close
      return
    end
   
   #get title
    t = doc.at("//div.asset-header/h1.asset-name")
    if t.nil?
      puts "Can't find title"
    else
      title=t.inner_text.strip
      title = title.gsub(/\\/,"").gsub("\"","\\\"")
      title.force_encoding('utf-8')
    end
    #get date
    d = doc.at("//div.asset-meta/span.byline")
    if d.nil?
      puts "Can't find date"
    else    
      date = Time.parse(d.inner_text.strip).strftime("%Y-%m-%d %H:%M:%S")
    end
    
    #get author
    author = "Danyelle Freeman"
    #get content
    content = ""
    cdiv = doc.at("//div.asset-content/div.asset-body")
    if cdiv.nil?
      puts "Can't find content"
    else
        begin  
          tmp = cdiv.inner_text
          tmp.force_encoding("utf-8")
          content= tmp
        rescue Encoding::CompatibilityError => encoding
          badurls.puts("EMPTY CONTENT #{encoding}: #{in_url}")
          puts "drop content, #{encoding}"
          badurls.close
        end
    end #endof cdiv.nil?
    content = content.gsub(/\\/,"").gsub(/\s+/," ").gsub("\"","\\\"")
    #get links
    linkarray = Array.new
    (cdiv/"//a").each do |each_link|
      if each_link.attributes['href'].nil?
        puts "Empty href"
      else
        linkarray << each_link.attributes['href']
      end
    end

    
    #get comments
    commentarray=Array.new
    doc.search("//div.comments-content/div.comment/div.inner").each do|each_c|
      commentHash=Hash.new
      cc = (each_c/"/div.comment-content")
      if cc.nil?
        puts "Can't find comment content?"
      else
        commentHash['content']=cc.inner_text.strip.gsub(/\\/,"").gsub("\"","\\\"").gsub(/\s+/," ")
      end
    
      ca = each_c.at("/div.comment-header")
      if ca.nil?
        puts "Can't find comment author"
      else
        if ca.inner_text.strip =~ /(.*)said/
          commentHash['author']=$1.strip
          commentHash['author']=commentHash['author'].gsub(/\\/,"").gsub("\"","\\\"")
        else
          puts "Can't parse comment author"
        end
      end#end of ca.nil
      cd = each_c.at("/div.comment-footer")
      if cd.nil?
        puts "Can't find comment date"
      else
        commentHash['date']=Time.parse(cd.inner_text.strip).strftime("%Y-%m-%d %H:%M:%S")
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
  
  site_id= 30
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
  test_url = "http://www.restaurantgirl.com/best_of/best_of_nycs_whoopie_pies.html"
  log_file = File.open("testlog","a+")
  parse(test_url, log_file)
  log_file.close
end #end of test main

def main
  log_file=File.open("restaurantgirl.log","a+")
  urls =File.open("urls","r+")
# urls =File.open("continue","r+")
  while url=urls.gets
    puts url.chomp
    parse(url.chomp, log_file)
  end#end of while
  log_file.close
  urls.close
end #end of main

end #end of class

blogparser_pipeline(Restaurantgirl)
