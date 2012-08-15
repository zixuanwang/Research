require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'
begin
  require 'system_timer'
  MyTimer = SystemTimer
rescue LoadError
  require 'timeout'
  MyTimer = Timeout
end

Hpricot.buffer_size = 262144

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

class Amateur 
  #include Normalize
  def parse(in_url,log)
    url = in_url.strip
    doc = nil
    begin
      MyTimer::timeout(3) do 
      doc = Hpricot(open(in_url))
      end
    rescue MyTimer::Error => timeout
      puts "Timeout"
      return
    rescue Exception => e
      puts e
      return
    end
    #shortpost
    short = doc.at("//div[@class='shortspost']")
    if !short.nil?
      return
    end
    puts url
    #get title
    t = doc.at("//div[@id='main-content']/h2")
    if t.nil?
      puts "Can't find title"
    else
      title = t.inner_text.strip.gsub("\"","\\\"")
    end
    
    #get date
    d = doc.at("//div[@class='entry']/p[@class='entry-footer']/span[@class='post-footers']")
    if d.nil?
      puts "Can't find author and date"
    else
      dd = d.inner_text.strip
      if dd =~ /Posted by(.*)on(.*)/
        author = $1.strip
        ddd = $2.strip
        date = Time.parse(ddd).strftime("%Y-%m-%d %H:%M:%S")
      else
          if dd =~ /Posted on(.*)/
            author = "anonymous"
            ddd = $1.strip
            date = Time.parse(ddd).strftime("%Y-%m-%d %H:%M:%S")
          else
            author = "anonymous"
            date =""
            puts "Can't parse author and date"
          end
      end
    end
    log.puts("URL",url,"AUTHOR", author, "DATE", date, "TITLE", title )
    #puts url, author, date,title
  
    #get content
    content = ""
    doc.search("//div[@class='entry-body']/p").each do |each_para| 
      begin  
      content += each_para.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
    end
    content = content.gsub("\"","\\\"")
    log.puts("CONTENT",content)
    #get links
    linkarray = Array.new
    doc.search("//div[@class='entry-body']//a").each do |each_link|
      if each_link.attributes['href'].nil?
        #puts "Empty href"
      else
        linkarray << each_link.attributes['href']
        #puts each_link.attributes['href']
      end
    end
    #get comments
    commentarray = Array.new
    doc.search("//div[@class='comments-content']//div[@class='comment-inner']").each do |each_c|
    c_doc = Hpricot(each_c.inner_html)
    commentHash = Hash.new
    cad = c_doc.at("/p[@class='comment-footer']")
    if cad.nil?
      puts "can't find commenter and date"
    else
      if cad.inner_text.strip =~ /Posted by\s+([^|]+)\s*\|\s*(.*)/
        #puts $1,$2
        ca = $1.strip
        cdd = $2.strip
        commentHash['author'] = ca.gsub("\"","\\\"")
        commentHash['date'] = Time.parse(cdd).strftime("%Y-%m-%d %H:%M:%S")
      end
    end
    
    cc=""
    c_doc.search("/div[@class='comment-content']//p").each do |each_p|
      begin
        cc += each_p.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
    end
      commentHash['content'] = cc.gsub("\"","\\\"")   
      commentarray<<commentHash if !commentHash.empty?
    end #end of comments.each
     
   log.puts("LINKS") 
   linkarray.uniq.each do |each_l|
     log.puts(each_l)
   end
   log.puts("COMMENTS")
   commentarray.each do |each_c|
     log.puts(each_c['author'],each_c['date'],each_c['content'])
   end
   site_id=11
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
    #test_url = "http://www.amateurgourmet.com/2004/01/gourmet_dinner_.html" 
    log_file=File.open("amateur.log", "a+")
    urls = File.open("continueUrl","r")
    while test_url = urls.gets
      parse(test_url, log_file)
    end
  end # end of main function
end #end of class

blogparser_pipeline(Amateur)
