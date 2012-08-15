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
  '&acirc;' =>'a', 
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

class Nycfoodie 
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
    t=doc.at("//div#maincontent/div.blog_subject")
    if t.nil?
      puts "Can't find title!"
    else
      title=t.inner_text.strip
      title = title.gsub(/\\/,"").gsub("\"","\\\"")
      title.force_encoding('utf-8')
    end
    
    #get date
    d = doc.at("//div#maincontent/div.blog_byline")
    if d.nil?
      puts "Can't find date!"
    else
      date = Time.parse(d.inner_text.strip).strftime("%Y-%m-%d %H:%M:%S")
    end
    
    #get author
    author = "Josh Beckerman" 
    
    body = doc.at("//div#maincontent")
    content = ""
    linkarray=Array.new
    nextnode ="" 
    body.each_child do |e|
     if e.inner_html.nil?
      next 
     else
       if e.text?
        content += e.to_s
       else
         if e == doc.at("//div#maincontent/br[@clear='all']")
           nextnode = e.next_sibling
           break
         else
           if e.name == "a"
             linkarray << e.attributes['href'].strip 
             content += e.inner_text.strip
           else
             next
           end
         end
       end
     end
    end #end of post content's each child
  
    content=content.strip.gsub(/\\/,"").gsub("\"","\\\"").gsub(/\s+/," ")
    flag = 0
    while 1 
      if nextnode.name == "a" 
        comm_url = nextnode.attributes['href'].strip
        if nextnode.inner_text.strip =~ /.*add comment.*/
          flag=0
        else
          flag=1
        end
       break
      else
        nextnode = nextnode.next_sibling
      end
    end #end of while
    
    commentarray = Array.new
    if flag==1
      prefix = "http://www.nycfoodie.com/nycfoodie/"
      comment_url = ""
      if comm_url =~ /javascript:openpopup\('(.*)',(.*),(.*),(.*)\)/
         comment_url = prefix +$1
      else
        puts "Can't parse comment link"
      end
      c_doc = Hpricot(open(comment_url)) 
      comm_node = c_doc.search("//div.blog_subject")
      j = comm_node.length
      k=1
      while k<j-1
        commentHash=Hash.new
        commentHash['author']=comm_node[k].at("/a").inner_text.strip
        date_node = comm_node[k].next_sibling
        if date_node.name=="div"
          commentHash['date']=Time.parse(date_node.inner_text.strip).strftime("%Y-%m-%d %H:%M:%S")
        else
          puts "Can't find comment date"
        end
        cc = ""
        nextnode = date_node.next_node
        while 1 
          if nextnode.nil? or nextnode.name == "div"
            break
          else
          if nextnode.text?
            cc += nextnode.to_s
          else
            cc += nextnode.inner_text.strip
          end
          nextnode = nextnode.next_node
          end
        end#endofwhile1 
        commentHash['content']=cc.strip.gsub(/\\/,"").gsub("\"","\\\"").gsub(/\s+/," ")       
        commentarray << commentHash
        k+=1
      end#end of j>1
    end#end of flag=1
  
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
   
  site_id = 35
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
      #puts "1 #{each_link}"
      if  each_link =~ /([^"]+)"(.*)/
        each_link = $1
      end
      #puts "2 #{each_link}"
      if each_link =~ /^https?:\/\/([^\/]*)\/?(.*)/
       # puts "3 #{each_link}"
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
      begin
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
      rescue Encoding::CompatibilityError => encode 
        puts "drop comment #{encode}"
        badurls.puts("DROP COMMENT #{encode}")
      end
    end # end of commentarray.each
  
  end # end of parse function

def test_main
  test_url = "http://www.nycfoodie.com/nycfoodie/index.php?entry=entry081028-172750"
  log_file = File.open("testlog","a+")
  parse(test_url, log_file)
  log_file.close
end #end of test main

def main
  log_file=File.open("nycfoodie.log","a+")
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

blogparser_pipeline(Nycfoodie)
