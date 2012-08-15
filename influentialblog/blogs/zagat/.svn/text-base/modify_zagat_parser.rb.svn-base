require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'
#encoding: utf-8
begin
  require 'system_timer'
  MyTimer = SystemTimer
rescue LoadError
  require 'timeout'
  MyTimer = Timeout
end

Hpricot.buffer_size = 262144
@TEST = 0
#@TEST = 1

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
  '&#8242;' =>'\'',
  '&#8243;' =>'"',
  '&#187;'  => '>>',
  '&#183;'  => '.',
  '&#39;'   =>'\'',
  '&#161;'  => 'i',
  '&#176;'  => '',
  '&#333;'  => 'o',
  '&#252;'  => 'u',
  '&#233;'  => 'e',
  '&#231;'  => 'c',
  '&#232;'  => 'e',
  '&#224;'  => 'a',
  '&#235;'  => 'e',
  '&#0160;' => ' ',
  '&#168;'  => '"',
  '&#180;'  => '\'',
  '&#151;'  => '--',
  '&#150;'  => '-',
  '&#x00ab;'=> '<<',
  '&#x00bb;'=> '>>',
  '&raquo;' => '>>',
  '&rsquo;' =>'\'',
  '&lsquo;' => '\'',
  '&laquo;' => '<<',
  '&ldquo;' => '"',
  '&rdquo;' => '"',
  '&mdash;' =>'-',
  '&ndash;' => '-',
  '&middot' => '|',
  '&nbsp;' => ' ',
  '&#148;' => '"',
  '&euml;'=>'e',
  '&Emul;'=>'E',
  '&ecirc;'=>'e',
  '&eacute;'=>'e',
  '&#063;' => '?',
  '&#038;' => '&',
  '&#x00bb;'=>'',
  '&#39;' => '\'',
  '&amp;' => '&',
  '&cent;' =>'cent',
  '&deg;'=>'degree',
  '&trade;'=>'TM',
  '&copy;' =>'',
  '&ntilde;'=>'n',
  '&lt;'=>'<',
  '&gt;'=>'>'
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

class Zagat
  include Normalize
  def parse(in_url,log)
    url = in_url.strip
    doc = nil
    badurls = File.open("badurls","a+")
    begin
      MyTimer::timeout(30) do 
      fullpage = Hpricot(open(in_url)).to_s
      normalize_text(fullpage)
      doc = Hpricot(fullpage)
      end
    rescue MyTimer::Error => timeout
      puts "#{timeout}"
      badurls.puts("#{timeout}: #{in_url}")
      badurls.close
      return
    rescue Exception => e
      badurls.puts("#{e}: #{in_url}")
      puts "When open url #{e}"
      badurls.close
      return
    end
    #get title
    t = doc.at("//div.blogHdr/h3")
    if t.nil?
      puts "Can't find title!"
    else
      title=t.inner_text.strip
    end
    title = title.gsub(/\\/,"").gsub("\"","\\\"")
    title.force_encoding('utf-8')
    #get date
    d = doc.at("//div.blogDate/h5")
    if d.nil?
      puts "Can't find date!"
    else
      d_date = d.inner_text.strip
    end
    
    dd = doc.at("//div.blogDate/h6")
    if dd.nil?
      puts "Can't find date!"
    else
      d_year = dd.inner_text.strip
    end

    date = Time.parse(d_date+" "+d_year).strftime("%Y-%m-%d %H:%M:%S")
    #get author
    author = "BuzzEditor" 
    #get content
    content = ""
    cdiv = doc.at("//div.blogBod")
    if cdiv.nil?
      puts "Can't find content"
    else
        begin  
          tmp = cdiv.inner_text.strip
          tmp.force_encoding("utf-8")
          content= tmp.gsub(/\\/,"").gsub(/\s+/," ").gsub("\"","\\\"")
        rescue Encoding::CompatibilityError => encoding
          puts "drop content, #{encoding}"
          badurls.puts("EMPTY CONTENT: #{encoding} #{in_url}")
          badurls.close
        rescue TypeError=>type
          puts "drop content, #{type}"
          badurls.puts("EMPTY CONTENT: #{type} #{in_url}")
          badurls.close
        rescue ArgumentError=>arg
          puts "drop url because, #{arg}"
          badurls.puts("EMPTY CONTENT: #{arg} #{in_url}")
          badurls.close
          return
        end
    end #endof cdiv.nil?
    #get links
    linkarray = Array.new
    prefix="http://www.zagat.com"
    (cdiv/"//a").each do |each_link|
      if each_link.attributes['href'].nil?
        puts "Empty href"
      else
        linkcontent = each_link.attributes['href']
        if linkcontent =~ /^\/(.*)/
          link_c = prefix + linkcontent
        else
          link_c = linkcontent
        end
        linkarray << link_c
      end
    end
    
   #get comments
        
   log.puts("***URL", url, "***TITLE", title, "***AUTHOR", author,"***DATE", date)
   log.puts("***CONTENT", content)
   log.puts("***LINKS: #{linkarray.size}")
   linkarray.uniq.each do |l|
    log.puts l
   end
  
  site_id = 32
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
    sql =<<-SQL
      select id from blogs where url = "#{url}"
    SQL
    blog_id = DBConnection::connection.select_all(sql)[0]["id"]
    else
      puts "EXEC UPDATE BLOGS"

      blog_id = DBConnection::connection.select_all(sql)[0]["id"]
      
      puts blog_id 
      sql =<<-SQL
        update blogs set publish_date = "#{date}" where id = #{blog_id}
      SQL
      DBConnection::connection.execute(sql) 
    end # end of if blog doesn't exist
     
    linkarray.uniq.each do |each_link|
      if  each_link =~ /([^"]+)"(.*)/
        each_link = $1
      end
      if each_link =~ /^https?:\/\/([^\/]*)\/(.*)/
        l_domain = $1
          sql =<<-SQL
            select id from outlinks where url = "#{each_link}"
          SQL
          link_exist = DBConnection::connection.select_all(sql)

          link_id = 0
          if link_exist.empty?
            puts "EXEC UPDATE LINKS"
            sql=<<-SQL
              insert into outlinks(url, domain)
              values("#{each_link}","#{l_domain}")
            SQL
            DBConnection::connection.execute(sql)
            sql=<<-SQL
              select id from outlinks where url = "#{each_link}"
            SQL
            link_id = DBConnection::connection.select_all(sql)[0]['id']
          else
            link_id = DBConnection::connection.select_all(sql)[0]['id']
          end  
          
          sql=<<-SQL
            select outlink_id from blogs_outlinks where outlink_id = #{link_id} and blog_id = #{blog_id}
          SQL
          dup = DBConnection::connection.select_all(sql)
          if dup.empty?
            puts "EXEC UPDATE BLOGS_OUTLINKS"
            sql=<<-SQL
              insert into blogs_outlinks(blog_id,outlink_id)
              values("#{blog_id}", "#{link_id}")
            SQL
            DBConnection::connection.execute(sql)
          end #end if dup.empty
          l_domain=""
      end # end of if link = http://
    end # end of links.each
    end # end of parse function

def test_main
  test_url = "http://www.zagat.com/Blog/Detail.aspx?SNP=NNYC&SCID=40&BLGID=8723"
  log_file = File.open("mod_testlog","a+")
  parse(test_url, log_file)
  log_file.close
end #end of test main

def main
  log_file=File.open("modify_zagat.log","a+")
  urls =File.open("urls","r+")
#  urls =File.open("continue","r+")
  while url=urls.gets
    puts url.chomp
    parse(url.chomp, log_file)
  end#end of while
  log_file.close
  urls.close
end #end of main
end #end of class

blogparser_pipeline(Zagat)
