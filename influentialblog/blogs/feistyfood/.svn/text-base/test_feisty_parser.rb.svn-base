require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'
#encoding: UTF-8
begin
  require 'system_timer'
  MyTimer = SystemTimer
rescue LoadError
  require 'timeout'
  MyTimer = Timeout
end

Hpricot.buffer_size = 262144

#@TEST = 1
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
  '&#39;'   =>'\'',
  '&#161;'  => 'i',
  '&#0160;' => ' ',
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
  '&#39;' => '\'',
  '&amp;' => '&',
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

class Feistyfoodie
include Normalize
def parse(in_url, log)
  url = in_url
  author = "Yvo"
  doc=nil
  begin
    MyTimer::timeout(30) do
      fullpage = Hpricot(open(in_url)).to_s
      normalize_text(fullpage)
      doc = Hpricot(fullpage)
    end
  rescue MyTimer::Error => timeout
    puts "Timeout"
    return
  rescue Exception => e
    puts e
    return
  end
  #get title
  t = doc.at("//div[@class='post hentry']/h3[@class='post-title entry-title']/a")
  if t.nil? or t.empty?
    puts "Can't find title"
  else
    title = t.inner_text.strip
  end
  title=title.gsub("\"","\\\"")
  title.force_encoding("utf-8")
  
  #get date-time
  dd = doc.at("//div[@class='post-footer']/div/span[@class='post-timestamp']/a/abbr")
  if dd.nil? or dd.empty?
    puts "Can't find timestamp"
  else
    in_date = dd.attributes["title"]
    if in_date.empty?
      puts "empty date?"
    else  
      date = Time.parse(in_date).strftime("%Y-%m-%d %H:%M:%S")
    end
  end
  
  #get content
  begin
    cdiv = doc.at("//div[@class='post-body entry-content']").inner_text
    cdiv.force_encoding("utf-8")
    content = cdiv
  rescue Encoding::CompatibilityError => encoding
    puts "content, #{encoding}, drop this url"
    return
  end
  content = content.gsub(/\\/,"").gsub(/\s+/," ").gsub("\"","\\\"") 

  #get links
  linkarray = Array.new
  doc.search("//div[@class='post-body entry-content']//a").each do|each_l|
    if each_l.attributes['href'].nil?
      puts "Empty href"
    else
      linkarray<<each_l.attributes['href']
    end
  end

  #get comments
  commentarray = Array.new
  
  loopnumber = 0
  numberpart = doc.at("//div[@id='comments']/h4")
  if numberpart.nil?
    puts "no comments"
  else
    numbersent=numberpart.inner_text.strip
    if numbersent =~ /(\d+)\scomments:(.*)/
      loopnumber=$1.to_i
    else
      loopnumber=0
    end
  end
  j = loopnumber
  while j>0
    commentarray[(j-1)] = Hash.new
    j -= 1
  end
 
  if loopnumber>0
    i=0
    doc.search("//dl[@id='comments-block']/dd[@class='comment-body']").each do|c|
      begin
        ctmp=c.inner_text
        ctmp.force_encoding("utf-8")
        ctmp = ctmp.gsub(/\\/,"").gsub("\"","\\\"").gsub(/\s+/," ")
        commentarray[i]['content']= ctmp.strip
      rescue Encoding::CompatibilityError => encoding
        puts "Comments content #{encoding}"
        commentarray[i]['content'] = ""
        i=i+1
        next
      end
      i=i+1
    end
   
    i=0
    doc.search("//dl[@id='comments-block']/dd[@class='comment-footer']/span[@class='comment-timestamp']/a").each do |t|
      cd = t.inner_text.strip
      if cd=~ /(\d+)\/(\d+)\/(\d+) (.*)/
        cdd = $3+"-"+$1+"-"+$2+" "+$4
      else
        puts "can't parse comment date"
      end
      #puts cdd
      commentarray[i]['date']=Time.parse(cdd).strftime("%Y-%m-%d %H:%M:%S")
      i=i+1
    end
    
    i=0
    doc.search("//dl[@id='comments-block']/dt").each do|a|
      aa = a.inner_text.strip
      if aa =~ /(.*)\s+said.../
        commentarray[i]['author']=$1.strip
        commentarray[i]['author']=commentarray[i]['author'].gsub(/\\/,"").gsub("\"","\\\"")
      else
        puts "Can't parse comment author"
      end
      i+=1
    end
  end # if there has comments

  log.puts("***URL", url, "***TITLE", title, "***AUTHOR", author,"***DATE", date)
  log.puts("***CONTENT", content)
  log.puts("***LINKS")
  linkarray.uniq.each do |l|
   log.puts l
  end
  log.puts("***COMMENTS: #{commentarray.size}")
  commentarray.each do |c|
    log.puts(c['author'])
    log.puts(c['date'])
    log.puts(c['content'])
  end
  
  site_id = 26
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

end

def test_main
  test_url = "http://feistyfoodie.blogspot.com/2009/05/palazzo-ristorante-pittsburgh.html"
  log_file = File.open("testlog","a+")
  parse(test_url, log_file)
  log_file.close
end #end of test main

def main
  log_file=File.open("feisty.log","a+")
  urls =File.open("urls","r+")
#  urls =File.open("continue","r+")
  while url=urls.gets
    puts url.chomp
    parse(url.chomp, log_file)
  end#end of while
  log_file.close
  urls.close
end #end of main
end # end of class

blogparser_pipeline(Feistyfoodie)
