require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'

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

class Foodmayhem
  include Normalize
  def parse(in_url, log)
    url = in_url
    puts url
    begin
    file = Hpricot(open(in_url)).to_s
    normalize_text(file)
    doc = Hpricot(file) 
    rescue => e
      puts e
    end
    url.encode("UTF-8")
    title,date,content,author=String.new,String.new,String.new,String.new
    title.encode("UTF-8")
    date.encode("UTF-8")
    content.encode("UTF-8")
    author.encode("UTF-8")
    #get title
    t = doc.at("//div[@class='article-header']/h2[@class='article-title']/a")
    if t.nil?
      puts "Can't find title"
    else
      title = t.inner_text.strip.gsub("\"","\\\"")
    end
    
    #get date
    d = doc.at("//div[@class='article-header']//h3[@class='date-header']")
    if d.nil?
      puts "Can't find date"
    else
      dd = d.inner_text.strip
    end
    
    #get author and time
    byline = doc.at("//div[@class='entry article-text']/p[@class='postmetadata alt article-footer']/span[@class='author']")
    author = "anonymous"
    time = " "
    if byline.nil?
      puts "Can't find author and time"
    else
      b = byline.inner_text.strip
      #puts b
      if b =~ /posted by (.*)at(.*)/
        author = $1.strip
        time = $2
      end
    end
    date = Time.parse(dd+time).strftime("%Y-%m-%d %H:%M:%S")
    author=author.gsub("\"","\\\"")
    log.puts("URL", url,"AUTHOR", author, "DATE", date, "TITLE", title)
    
    #get content
    doc.search("p[@class='postmetadata alt article-footer']").remove
    content = ""
    doc.search("//div[@class='entry article-text']//p").each do |each_para| 
      begin  
      content += each_para.inner_text.strip
      rescue TypeError => typing
        puts typing 
        next
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
    end
    content = content.gsub("\"","\\\"").gsub(/\s+/, " ")
    log.puts("CONTENT", content)
    #get links
    linkarray = Array.new
    log.puts("LINKS")
    doc.search("//div[@class='entry article-text']//a").each do |each_link|
      if each_link.attributes['href'].nil?
        puts "Empty href"
      else
        linkarray << each_link.attributes['href']
        log.puts(each_link.attributes['href'])
      end
    end
    #get comments
    commentarray = Array.new
    log.puts("COMMENTS")
    doc.search("//div[@id='comments']/ol[@class='commentlist']/li").each do |each_c|
    c_doc = Hpricot(each_c.inner_html)
    commentHash = Hash.new 
    ca = c_doc.at("//div[@class='comment-author vcard']/cite[@class='fn']")
    if ca.nil?
      commentHash['author'] ="anonymous"
      puts "Can't find author"
    else
      commentHash['author']=ca.inner_text.strip.gsub("\"","\\\"")
    end
    log.puts(commentHash['author'])
    cd = c_doc.at("//div[@class='comment-meta commentmetadata']")
    if cd.nil?
      puts "Can't find comment date?"
      commentHash['date']=""
    else
      tcd = cd.inner_text.strip
      commentHash['date']=Time.parse(tcd).strftime("%Y-%m-%d %H:%M:%S")
    end
    log.puts(commentHash['date'])
    cc=""
    c_doc.search("/div//p").each do |each_p|
      begin
        cinner=""
        cinner= each_p.inner_text.to_s
        if !cinner.nil? and !cinner.empty?
          cc += cinner.strip
        end
      rescue TypeError => type
        puts type
        next
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
      end
      log.puts(cc)
      commentHash['content'] = cc.gsub("\"","\\\"")   
    end #end of comments.each
  
    site_id=10
    sql =<<-SQL
      select blog_id from blogs where blog_url = "#{url}"
    SQL
    blog_exist = DBConnection::connection.select_all(sql)
    blog_id = 0
    puts("************")
    puts(url.encoding.name, date.encoding.name,author.encoding.name,content.encoding.name,title.encoding.name)
    
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
    urlist = File.open("urls","r")
    log_file=File.open("foodmayhem.log", "a+")
    while line = urlist.gets
      test_url = line.strip
      parse(test_url, log_file) 
    end
  end # end of main function
end #end of class

blogparser_pipeline(Foodmayhem)
