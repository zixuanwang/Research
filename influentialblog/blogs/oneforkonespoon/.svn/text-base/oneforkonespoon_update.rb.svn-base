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
  '&lsquo;' => '<<',
  '&nbsp;' => ' ',
  '&#148;' => '"',
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

class Oneforkonespoon
include Normalize
def parse(in_url, log)
  url = in_url
  author = "AppleSister"
  doc=nil
  begin
    MyTimer::timeout(3) do
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
  t = doc.at("//div[@class='post hentry uncustomized-post-template']/h3[@class='post-title entry-title']/a")
  if t.nil? or t.empty?
    puts "Can't find title"
  else
    title = t.inner_text.strip
  end
  title=title.gsub("\"","\\\"")
  
  #get date-time
  dd = doc.at("//div[@class='post-footer-line post-footer-line-1']/span[@class='post-timestamp']/a/abbr")
  if dd.nil? or dd.empty?
    puts "Can't find timestamp"
  else
    in_date = dd.attributes["title"]
    date = Time.parse(in_date).strftime("%Y-%m-%d %H:%M:%S")
  end
  
  #get content
  begin
    content = doc.at("//div[@class='post-body entry-content']").inner_text.strip
  rescue Encoding::CompatibilityError => encoding
    puts "content, #{encoding}"
    return
  end
  content = content.gsub(/\s+/," ").gsub("\"","\\\"") 

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
        commentarray[i]['content']= c.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts "Comments content #{encoding}"
        commentarray[i]['content'] = ""
        i=i+1
        next
      end
      commentarray[i]['content']=commentarray[i]['content'].gsub("\"","\\\"").gsub(/\s+/," ")
      i=i+1
    end
   
    i=0
    doc.search("//dl[@id='comments-block']/dd[@class='comment-footer']/span[@class='comment-timestamp']/a").each do |t|
      commentarray[i]['date']=Time.parse(t.inner_text.strip).strftime("%Y-%m-%d %H:%M:%S")
      i=i+1
    end
    
    i=0
    doc.search("//dl[@id='comments-block']/dt").each do|a|
      aa = a.inner_text.strip
      if aa =~ /(.*)\s+said.../
        commentarray[i]['author']=$1.strip
      else
        puts "Can't parse comment author"
      end
      i+=1
    end
  end # if there has comments

  log.puts("***URL", url, "***TITLE", title, "***AUTHOR", author,"***DATE", date)
  log.puts("***CONTENT", content)
  linkarray.uniq.each do |l|
   log.puts l
  end
  log.puts("***COMMENTS")
  commentarray.each do |c|
    log.puts(c['author'])
    log.puts(c['date'])
    log.puts(c['content'])
  end
  site_id = 14
  sql =<<-SQL
    select blog_id from blogs where blog_url = "#{url}"
  SQL
  blog_exist = DBConnection::connection.select_all(sql)
  blog_id = 0
    
  if blog_exist.empty?
    puts("EEEERRORRRR!")
  else
      blog_id = DBConnection::connection.select_all(sql)[0]["blog_id"]
  end # end of if blog doesn't exist
  puts blog_id      
    
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
    else
      comment_id = DBConnection::connection.select_all(sql)[0]["comment_id"]
      puts comment_id
      sql=<<-SQL
        update comments set blog_id = #{blog_id} and author_name = "#{each_c['author']}" and publish_date = "#{each_c['date']}" and content="#{each_c['content']}" where comment_id = #{comment_id} 
      SQL
      DBConnection::connection.execute(sql)
      puts "#{comment_id} updated!"
    end
  end # end of commentarray.each

end

def test_main
  test_url="http://oneforkonespoon.blogspot.com/2008/04/easy-enchiladas.html"
  log_file = File.open("testlog","a+")
  parse(test_url, log_file)
  log_file.close
end #end of test main

def main
  log_file=File.open("updatecomments.log","a+")
  urls =File.open("urls","r+")
  while url=urls.gets
    puts url.chomp
    parse(url.chomp, log_file)
  end#end of while
  log_file.close
  urls.close
end #end of main
end # end of class

blogparser_pipeline(Oneforkonespoon)
