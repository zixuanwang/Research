require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'
require 'time'

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
end # end of module
 
#Here is the use of the Abstract Factory pattern
def blogparser_pipeline(factory)
  new_site = factory.new
  new_site.main
  puts "created a new  #{new_site.class} with a factory"
end

class Eatsblog
  include Normalize
  def parse(post_url, log_file)
    begin
      doc=Hpricot(open(post_url))
    rescue => e
      puts e 
      return -1
    end
    
    #get url
    url = post_url
    log_file.puts("URL")
    log_file.puts(url)
    #get title
    t = doc.at("//div[@class='entry']/h3[@class='entry-header']/a")
    if t.nil?
      puts "Can't find title"
    else
      title = t.inner_text
    end
    title = title.gsub("\"","\\\"")
    log_file.puts("TITLE")
    log_file.puts(title)
    #get author
    a = doc.at("//span[@class='authorname']")
    if a.nil? 
      puts "Can't find author"
      author = "anonymous"
    else
      author = a.inner_text
    end
    author.gsub!("\"","\\\"")
    log_file.puts("AUTHOR")
    log_file.puts(author)
    #get timestamp
    t = doc.at("//table[@id='blog-body-heading']/tr/td/table/tr[2]/td")
    if  t.nil?
      puts "Can't find time"
    else
      if t.inner_text.strip.empty? or t.inner_text.nil?
        puts "td empty!"
        t2 = doc.at("//table[@id='blog-body-heading']/tr/td/table/tr[2]/td[2]")
        if t2.nil? or t2.empty?
          puts "Can't find td[2]!"
        else 
          d_text = t2.inner_text.strip
        end
      else
        puts "td1 not empty"
        d_text = t.inner_text.strip
      end
      if d_text.strip =~ /([^|]+)|(.*)/
        tstamp = $1
        date  =  Time.parse(tstamp).strftime("%Y-%m-%d %H:%M:%S")
      end
    end
    log_file.puts(date)
    #get content
    content = ""
    doc.search("//div[@id='blog-body']//p").each do |para|
      begin
      content += para.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
    end
    content = content.gsub("\"","\\\"").gsub(/\s+/," ")
    log_file.puts("CONTENT")
    log_file.puts(content)
    #get links
    linkarray = Array.new
    doc.search("//div[@id='blog-body']//p//a").each do |each_l|
      if each_l.attributes['href'].nil?
        puts "Empty <a>?"
      else
        linkarray << each_l.attributes['href']
      end
    end
    log_file.puts("LINKS")
    linkarray.uniq.each do |each_l|
      log_file.puts(each_l)
    end
    #get comments
    comment_array=Array.new
    doc.search("//div[@id='comments']/div[@class='comments-content']/div[@class='comment']/div[@class='inner']").each do |each_c|
      if each_c.inner_html.empty?
        puts("Empty comments?")
      else
        in_comment = Hpricot(each_c.inner_html)
        single_comment = Hash.new
        byline = in_comment.at("/div[@class='comment-header']/span[@class='byline']")
        if  byline.nil?
          puts "can't find comment byline"
        else
          byline = byline.inner_text.strip
          if byline=~/Posted by ([^@]+)@(.*)/
      #      puts $1, $2
            a = $1.strip
            b = $2.strip
            single_comment['author'] = a.gsub("\"","\\\"")
            single_comment['date'] = Time.parse(b).strftime("%Y-%m-%d %H:%M:%S")
          end
        end # end if byline.nil?
          cc = in_comment.at("//div[@class='comment-content']").inner_text.strip
        single_comment['content'] = cc.gsub("\"","\\\"").gsub(/\s+/," ")
      end #end if each_c.inner_html.empty?
     comment_array << single_comment 
    end #end of get  comments
    log_file.puts("COMMENTS:")
    comment_array.each do |each_c|
      log_file.puts(each_c['author'])
      log_file.puts(each_c['date'])
      log_file.puts(each_c['content'])
    end
    site_id=9
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
      if each_link =~/^https?:\/\/([^\/]*)\/.*/
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
    
    comment_array.each do |each_c|
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
    end # end of comment_array.each
  end # end of parse function
  
  def main
    urls = File.open("eatsblog.urls")
    log=File.open("eatsblog.log","a+")
    count = 0
    while test_url = urls.gets
      parse(test_url.strip, log)
      count += 1
    end
    puts("#{count} URLs have been processed")
  end # end of main function
end #end of class

blogparser_pipeline(Eatsblog)
