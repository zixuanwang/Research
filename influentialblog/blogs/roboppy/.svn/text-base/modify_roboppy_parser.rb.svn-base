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
  '&#161;' => 'i',
  '&#168;'  => '"',
  '&#180;'  => '\'',
  '&#151;'  => '--',
  '&#150;'  => '-',
  '&#x00ab;'=> '<<',
  '&#x00bb;'=> '>>',
  '&raquo;' => '>>',
  '&laquo;' =>'<<',
  '&lsquo;' => '<<',
  '&nbsp;' => ' ',
  '&#148;' => '"',
  '&#063;' => '?',
  '&#038;' => '&',
  '&#x00bb;'=>'',
  '&#39;'  => '\'',
  '&mdash;' => '-',
  '&amp;'  =>'&',
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

class Roboppy
include Normalize
def parse(in_url, log)
  url = in_url
  author = "roboppy"
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
  t = doc.at("//div[@id='content-main']/h3[@class='title']")
  if t.nil? or t.empty?
    puts "Can't find title"
  else
    title = t.inner_text.strip
    title=title.gsub("\"","\\\"")
  end
  
  #get date-time
  dhalf = doc.at("//div[@id='content-main']/h2[@class='date']")
  if dhalf.nil?
    puts "Can't find date!"
  else
    ddate = dhalf.inner_text.strip
  end
  dd = doc.at("//div[@id='content-main']/p[@class='posted']/a")
  dtime=""
  if dd.nil? or dd.empty?
    puts "Can't find timestamp"
  else
    dtime = dd.inner_text.strip
  end
  if ddate.empty? or ddate.nil?
    date=""
  else
    d_text = ddate+" "+dtime
    date = Time.parse(d_text).strftime("%Y-%m-%d %H:%M:%S")
  end
  #get content
  doc.search("//div[@id='content-main']/a[@name='more']").remove
  doc.search("//div[@id='content-main']/p[@class='posted']").remove
  doc.search("//div[@id='content-main']/p[@class='tags']").remove
  
  content=""
  elm = doc.at("//div[@id='content-main']/h3[@class='title']").next_sibling
  while 1
    if elm.name=='p' or elm.name=='ul'
      begin 
        content += elm.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts "content, #{encoding}"
      rescue TypeError=>typerror
        puts "content, #{typerror}"
      end
    end
    if elm.next_sibling.nil?  or elm.next_sibling.name=='h2' 
      break
    else
      elm = elm.next_sibling
    end
  end #end of all para
  content = content.gsub(/\\/,"").gsub(/\s+/," ").gsub("\"","\\\"") 

  #get links
  linkarray = Array.new
  doc.search("//div[@id='content-main']//p//a").each do|each_l|
    if each_l.attributes['href'].nil?
      puts "Empty href"
    else
      linkarray<<each_l.attributes['href']
    end
  end
  
  #get comments
  commentarray = Array.new
  startnode = doc.at("//div[@id='content-main']/h2[@id='comments']")
  #puts doc.at("//div[@id='content-main']")
  
  if startnode.nil?
    puts "No comments?"
  else
    node = startnode.next_sibling
    #puts node
    while !node.nil? and node.name!='h2'
      c_doc = Hpricot(node.inner_html)
      commentHash = Hash.new
      cad = c_doc.at("//p[@class='comment-posted']")
      if cad.nil?
        puts "Can't find commentor and date"
      else
        cadtext = cad.inner_text.strip
        if cadtext =~ /Posted by:(.*)at([^\[]+)\[(.*)/
          commentHash['author']=$1.strip
          cdate=$2
          commentHash['date']=Time.parse(cdate).strftime("%Y-%m-%d %H:%M:%S")
          commentHash['author']=commentHash['author'].gsub("\"","\\\"")
        else
          puts "Can't parser commentor and date"
        end
      end# end of commentor and date
      commentHash['content']=""
      c_doc.search("//p[@class='comment-posted']").remove
      c_doc.search("/div/p").each do|cc|
        if cc.nil?
          puts "Can't find comment content"
        else
          commentHash['content'] += cc.inner_text.strip
        end
      end
      commentHash['content']=commentHash['content'].gsub(/\\/,"").gsub("\"","\\\"").gsub(/\s+/," ")
      commentarray<<commentHash
      node = node.next_sibling
    end
  end #end if startnode is not nil
  
    log.puts("***URL", url, "***TITLE", title, "***AUTHOR", author,"***DATE", date)
    log.puts("***CONTENT", content)
    log.puts("***LINKS")
    linkarray.uniq.each do |l|
     log.puts l
    end
    log.puts("***COMMENTS")
    commentarray.each do |c|
      log.puts(c['author'])
      log.puts(c['date'])
      log.puts(c['content'])
    end
  
  site_id = 15
  sql =<<-SQL
    select id from blogs where url = "#{url}"
  SQL
  blog_exist = DBConnection::connection.select_all(sql)
  blog_id = 0
    
  if blog_exist.empty?
    puts("insert into db: #{url}")
    sql = <<-SQL
       insert into blogs (site_id, id,url,publish_date, author,content, title) 
       values ("#{site_id}",null,"#{url}","#{date}","#{author}","#{content}","#{title}")
    SQL
    DBConnection::connection.execute(sql)
    sql = <<-SQL
      select id from blogs where url = "#{url}"
    SQL
    blog_id = DBConnection::connection.select_all(sql)[0]["id"]
  else
      blog_id = DBConnection::connection.select_all(sql)[0]["id"]
      puts "UPDATE BLOGS: #{blog_id}"
      sql=<<-SQL
        update blogs set publish_date="#{date}" where id = #{blog_id}
      SQL
      DBConnection::connection.execute(sql)
  end # end of if blog doesn't exist
     
 # linkarray.uniq.each do |each_link|
 #   if  each_link =~ /([^"]+)"(.*)/
 #     each_link = $1
 #   end
 #   if each_link =~ /^https?:\/\/([^\/]*)\/(.*)/
 #       l_domain = $1
 #       sql =<<-SQL
 #          select id from link_info where link_url = "#{each_link}"
 #       SQL
 #       link_exist = DBConnection::connection.select_all(sql)
 #       link_id = 0
 #       if link_exist.empty?
 #           sql=<<-SQL
 #             insert into link_info(link_url, link_domain)
 #             values("#{each_link}","#{l_domain}")
 #           SQL
 #           DBConnection::connection.execute(sql)
 #           sql=<<-SQL
 #             select id from link_info where link_url = "#{each_link}"
 #           SQL
 #           link_id = DBConnection::connection.select_all(sql)[0]['id']
 #       else
 #           link_id = DBConnection::connection.select_all(sql)[0]['id']
 #       end  
 #         
 #       sql=<<-SQL
 #         select id from blog_links where link_id = #{link_id} and blog_id = #{blog_id}
 #       SQL
 #       dup = DBConnection::connection.select_all(sql)
 #       if dup.empty?
 #         sql=<<-SQL
 #             insert into blog_links(blog_id,link_id)
 #             values("#{blog_id}", "#{link_id}")
 #         SQL
 #         DBConnection::connection.execute(sql)
 #         sql =<<-SQL
 #             insert into outlinks(blog_id, link_id, link, link_domain)
 #             values("#{blog_id}",null, "#{each_link}","#{l_domain}")
 #         SQL
 #         DBConnection::connection.execute(sql)
 #       end #end if dup.empty
 #       l_domain=""
 #   end # end of if link = http://
 # end # end of links.each
 #   
 # commentarray.each do |each_c|
 #   sql=<<-SQL
 #     select comment_id from comments where blog_id = #{blog_id}
 #         and author_name = "#{each_c['author']}" and publish_date = "#{each_c['date']}"
 #         and content = "#{each_c['content']}"
 #   SQL
 #   comment_exist = DBConnection::connection.select_all(sql) 
 #   if comment_exist.empty?
 #       sql=<<-SQL
 #         insert into comments(blog_id, comment_id, author_name,publish_date,content)
 #         values("#{blog_id}",null,"#{each_c['author']}","#{each_c['date']}","#{each_c['content']}")
 #       SQL
 #       DBConnection::connection.execute(sql)
 #   end
 # end # end of commentarray.each
end

def test_main
  test_url="http://www.roboppy.net/food/2008/12/string-beans-and-more-from-famous-sichuan-chinatown-nyc.html"
  log_file = File.open("testlog","w")
  parse(test_url, log_file)
  log_file.close
end #end of test main

def main
  log_file=File.open("roboppy.log","a+")
  urls =File.open("urls","r+")
  while url=urls.gets
    puts url.chomp
    parse(url.chomp, log_file)
  end#end of while
  log_file.close
  urls.close
end #end of main
end # end of class

blogparser_pipeline(Roboppy)
