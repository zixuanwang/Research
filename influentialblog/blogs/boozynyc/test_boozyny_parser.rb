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

class Boozynyc
include Normalize
def parse(in_url, log)
  url = in_url
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
  t = doc.at("//div[@class='asset-header']/h1[@id='page-title']")
  if t.nil? or t.empty?
    puts "Can't find title"
  else
    title = t.inner_text.strip
    title=title.gsub("\"","\\\"")
  end
  
  #get author
  a = doc.at("//div[@class='asset-meta']//span[@class='vcard author']")
  if a.nil? or a.empty?
    puts "Can't find author"
  else
    author = a.inner_text.strip
  end
  
  ddate = doc.at("//div[@class='asset-meta']/span[@class='byline']/abbr[@class='published']")
  if ddate.nil? or ddate.empty?
    puts "Can't find date"
  else
    dtimestamp = ddate.inner_text.strip
    date = Time.parse(dtimestamp).strftime("%Y-%m-%d %H:%M:%S")
  end
  
  #get content
  content=""
  if doc.at("//div[@class='asset-content entry-content']/div[@class='asset-body']").nil?
    puts "Can't find content"
  else
    begin
      content = doc.at("//div[@class='asset-content entry-content']/div[@class='asset-body']").inner_text
      content = content.gsub(/\s+/," ").gsub(/\\/,"").gsub("\"","\\\"")
    rescue Encoding::CompatibilityError =>encoding
      puts "#{encoding}, drop this url "
      return
    end
  end

  #get links
  linkarray = Array.new
  doc.search("//div[@class='asset-body']//a").each do|each_l|
    if each_l.attributes['href'].nil?
      puts "Empty href"
    else
      linkarray<<each_l.attributes['href']
    end
  end
  
  #get comments
  commentarray = Array.new
  doc.search("//div[@class='comments-content']/div[@class='comment']").each do |each_c|
    c_doc = Hpricot(each_c.inner_html)
    commentHash=Hash.new
    ca = c_doc.at("//span[@class='byline']/span[@class='vcard author']")
    if ca.nil?
      puts "Can't find comment author"
    else
      commentHash['author']=ca.inner_text.strip
    end
    cd = c_doc.at("//span[@class='byline']/a/abbr[@class='published']")
    if cd.nil?
      puts "Can't find comment date"
    else
      commentHash['date']=Time.parse(cd.inner_text.strip).strftime("%Y-%m-%d %H:%M:%S")
    end
    cc = c_doc.at("//div[@class='comment-content']")
    if cc.nil?
      puts "Can't find comment content"
    else
      commentHash['content']=cc.inner_text.strip
      commentHash['content']=commentHash['content'].gsub(/\\/,"").gsub("\"","\\\"").gsub(/\s+/," ")
    end
    commentarray<<commentHash
  end #enf of comments
  if @TEST == 1
    puts url,title,author,date
    puts content
    linkarray.uniq.each do|l|
      puts l
    end
    commentarray.each do|c|
      puts c['author']
      puts c['date']
      puts c['content']
    end
  else
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
  end
  
  site_id = 16
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
  test_url = "http://boozynyc.com/2009/04/no-byob-in-nyc.html"
  log_file = File.open("testlog","w")
  parse(test_url, log_file)
  log_file.close
end #end of test main

def main
  log_file=File.open("boozynyc.log","a+")
  urls =File.open("urls","r+")
  while url=urls.gets
    puts url.chomp
    parse(url.chomp, log_file)
  end#end of while
  log_file.close
  urls.close
end #end of main
end # end of class

blogparser_pipeline(Boozynyc)
