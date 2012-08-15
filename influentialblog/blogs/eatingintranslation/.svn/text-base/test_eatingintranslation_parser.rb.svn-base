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
  '&laquo;' => '<<',
  '&middot' => '|',
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

class Eatingintranslation 
  include Normalize
  def parse(in_url,log)
    url = in_url.strip
    doc = nil
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
    t = doc.at("//div[@id='alpha-inner']/div[@class='entry']/h3[@class='entry-header']")
    if t.nil?
      puts "Can't find title"
    else
      title = t.inner_text.strip.gsub("\"","\\\"")
    end
    
    #get date
    d = doc.at("//div[@class='entry-footer']/p[@class='entry-footer-info']/span[@class='post-footers']")
    if d.nil?
      puts "Can't find author and date"
    else
      dd = d.inner_text.strip
      if dd =~ /(.*)in(.*)/
        ddd = $1.strip
        date = Time.parse(ddd).strftime("%Y-%m-%d %H:%M:%S")
      else
        date = Time.parse(dd).strftime("%Y-%m-%d %H:%M:%S")
      end
    end
    #get author
    author = "Dave Cook"
  
    #get content
    content = ""
    body = doc.at("//div[@class='entry-body']")
    begin  
      content = body.inner_text.strip
    rescue Encoding::CompatibilityError => encoding
      puts encoding
      return
    end
    content = content.gsub(/\\/,"").gsub(/\s+/," ").gsub("\"","\\\"")
    #get links
    linkarray = Array.new
    doc.search("//div[@class='entry-body']//a").each do |each_link|
      if each_link.attributes['href'].nil?
        puts "Empty href"
      else
        linkarray << each_link.attributes['href']
      end
    end
    
    #get comments
    commentarray = Array.new
    while 1
      doc.search("//div[@class='comments']/div[@class='comments-content']/div").each do |each_c|
        c_doc = Hpricot(each_c.inner_html)
        commentHash = Hash.new
        cad = c_doc.at("/p[@class='comment-footer']")
        if cad.nil?
          puts "can't find commenter and date"
        else
          #puts cad.inner_text.strip
          if cad.inner_text.strip =~ /Posted by:\s+([^|]+)\s*\|\s*(.*)/
          # puts $1,$2
            ca = $1.strip
            cdd = $2.strip
            commentHash['author'] = ca.gsub("\"","\\\"")
            commentHash['date'] = Time.parse(cdd).strftime("%Y-%m-%d %H:%M:%S")
          else
            puts "Can't parser comment's author and date"
          end
        end
      
        cc=""
        comment_body=c_doc.at("/div[@class='comment-content']")
        if !comment_body.nil? 
          begin
            cc = comment_body.inner_text.strip
          rescue Encoding::CompatibilityError => encoding
            puts "comments #{encoding}"
          end
        end
        commentHash['content'] = cc.gsub(/\\/,"").gsub("\"","\\\"")   
        commentarray<<commentHash if !commentHash.empty?
      end #end of comments.each
    
      nextpage=doc.at("//div[@class='comments']/div[@class='pager-bottom pager-comments pager content-nav']/div[@class='pager-inner']/span[@class='pager-right']/a")
      if nextpage.nil?
        break
      else
        puts "Another comment page.."
        nexturl = nextpage.attributes['href'].strip
        doc= Hpricot(open(nexturl))
      end
    end # end of while 1
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
   
  site_id=20
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
  #test_url="http://www.eatingintranslation.com/2009/01/whats-it-all-ab.html"
  test_url = "http://www.eatingintranslation.com/2009/03/i-love-py-bakery-cafe.html"
  log_file = File.open("testlog","a+")
  parse(test_url, log_file)
  log_file.close
end #end of test main

def main
  log_file=File.open("eatingintranslation.log","a+")
  urls =File.open("urls","r+")
  while url=urls.gets
    puts url.chomp
    parse(url.chomp, log_file)
  end#end of while
  log_file.close
  urls.close
end #end of main

end #end of class

blogparser_pipeline(Eatingintranslation)
