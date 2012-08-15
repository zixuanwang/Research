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

class Foodwine 
  include Normalize
  def parse(in_url,log)
    url = in_url
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
    t = doc.at("//div[@class='entry-excerpt']/div[@class='entryLast']/h1/a")
    if t.nil?
      puts "Can't find title"
    else
      title = t.inner_text.strip.gsub("\"","\\\"")
    end
    #puts title
    #get author
    t = doc.at("//div[@class='entry-excerpt']/div[@class='entryLast']/div[@class='byline']")
    if t.nil? or t.empty?
      puts "can't find author"
    else
      tt = t.inner_text.strip
      if tt =~ /B[Yy]([^,]+),(.*)/
        author = $1.strip
      end
    end
    author = author.gsub("\"","\\\"")
    #puts author 
   
    #get date
    d = doc.at("//div[@class='entry-excerpt']/div[@class='entryLast']/div[3]")
    if d.nil?
      puts "Can't find date"
    else
      dd = d.inner_text.strip
      if dd =~ /Posted(.*)(EST)?(EDT)?(.*)/
        ddd = $1.strip
        date = Time.parse(ddd+" EST").strftime("%Y-%m-%d %H:%M:%S")
       end # end of if d.nil
    end
    #puts date
    log.puts("URL",url,"AUTHOR", author, "DATE", date, "TITLE", title )
    #get content
    content = ""
    doc.search("//div[@class='imgContainer']/p[@class='creditcont']").remove
    begin
     content += doc.at("//div[@class='body']").inner_text.strip
    rescue Encoding::CompatibilityError => encoding
      puts encoding
      return
    end
    content = content.gsub("\"","\\\"")
    log.puts("CONTENT",content)
    #puts content
    #get links
    linkarray = Array.new
    doc.search("//div[@class='body']//a").each do |each_link|
      if each_link.attributes['href'].nil?
        puts "Empty href"
      else
        linkarray << each_link.attributes['href']
        #puts each_link.attributes['href']
      end
    end
        
   log.puts("LINKS") 
   linkarray.uniq.each do |each_l|
     log.puts(each_l)
   end
 
  site_id=13
   sql =<<-SQL
      select blog_id from blogs where blog_url = "#{url}"
   SQL
   blog_exist = DBConnection::connection.select_all(sql)
   blog_id = 0
    
   #puts url.encoding, author.encoding, date.encoding, title.encoding
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
    end # end of parse function

  def main
    log_file=File.open("foodwine.log", "a+")
    urls = File.open("urls","r")
    while test_url = urls.gets
      parse(test_url, log_file)
    end
  end # end of main function
end #end of class

blogparser_pipeline(Foodwine)
