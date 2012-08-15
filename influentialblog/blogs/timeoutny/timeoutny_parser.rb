require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'
# encoding: utf-8

Hpricot.buffer_size = 262144
class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",                                                  
                                  :host => "pierce.rutgers.edu",
                                  :username => "root",                                                  
                                  :password => "",
                                  :database => "Weblog")


module Normalize
def normalize_url(url)
   url_char = {
  '%20' => ' ',
  '%2F' => '/',
  '%3A' => ':',
  '%3F' => '?',
  '%e2%80%99' => '\'',
  '%e2%80%94' => '-',
  '%c2%a1' => 'i'
   }

  url_char.each do |key, value|
    url.gsub!(key,value)
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
  new_site.main
  puts "created a new  #{new_site.class} with a factory"
end

class Timeoutny
  include Normalize
  def parse(in_url, log)
    normalize_url(in_url)
    url = in_url
    
    begin
      wholefile = Hpricot(open(in_url)).to_s
      normalize_text(wholefile)
      doc = Hpricot(wholefile) 
    rescue => e
      puts e
      return
    end
    #get title
    t = doc.at("//div[@class='post LY_clear']/h2/a")
    if t.nil?
      puts "Can't find title"
    else
      title = t.inner_text.strip.gsub("\"","\\\"")
    end
    #get date and author
    d = doc.at("//div[@class='wp-byline']")
    if d.nil?
      puts "Can't find byline"
    else
      dd = d.inner_text.strip
      if dd =~ /.*by(.*)on(.*)/
        author = $1.strip
        in_date = $2.strip
      end
    end
  
    date = Time.parse(in_date).strftime("%Y-%m-%d %H:%M:%S")
    log.puts("***URL***", url, "***AUTHOR***",author,"***DATE***",date,"**TITLE***",title)
     
    #get content
    content = ""
    doc.search("//div[@class='entry']//p").each do |each_para| 
      begin  
      content += each_para.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
    end
    content = content.gsub("\"","\\\"")
    
    if content.empty?
      puts "empty content for: #{url}"
    end
    log.puts ("***CONTENTS***")
    log.puts(content)
    log.puts ("***LINKS***")
    #get links
    linkarray = Array.new
    doc.search("//div[@class='entry']//a").each do |each_link|
      if each_link.attributes['href'].nil?
        puts "Empty href"
      else
        linkarray << each_link.attributes['href']
       log.puts(each_link.attributes['href'])
      end
    end
    
    #get comments
    commentarray = Array.new
    doc.search("//ol[@class='comments']/li[@class='comment']").each do |each_c|
    c_doc = Hpricot(each_c.inner_html)
    commentHash = Hash.new 
    ca = c_doc.at("//div[@class='comment-byline']")
    if ca.nil?
      commentHash['author'] ="anonymous"
      puts "Can't find author and date"
    else
      cad = ca.inner_text.strip
      if cad =~ /Posted by(.*)on(.*)/
        commentHash['author']=$1.strip
        cdt = $2.strip
        commentHash['date'] = Time.parse(cdt).strftime("%Y-%m-%d %H:%M:%S")
      end
    end  
    cc=""
    c_doc.search("//p").each do |each_p|
      begin
        cc += each_p.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
    end # end of comment p
    commentHash['content'] = cc.gsub("\"","\\\"")  
    commentarray<<commentHash
    end #end of comments.each
   
    log.puts("***COMMENTS***")
    commentarray.each do|each_c|
      log.puts( each_c["author"] )
      log.puts( each_c["date"] )
      log.puts( each_c["content"] )
    end
   site_id=12
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
  
  def main
    urls = File.open("urls","r+")
    log_file=File.open("timeoutny.log", "a+")
    while line=urls.gets
      parse(line.strip, log_file)
    end
  end # end of main function
end #end of class

blogparser_pipeline(Timeoutny)
