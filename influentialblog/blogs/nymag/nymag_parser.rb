require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'

def is_blog(url_or_path) 
 if url_or_path =~ /^http/ 
   (url_or_path =~ (/^http:\/\/[^\/]+\/daily/)) ? true : false
 else 
   (url_or_path =~ (/^\/daily/)) ? true : false
 end
end

def get_article_id_by_url(url) 
  if url =~ (/^http/)
    url.sub!(/^http:\/\/[^\/]+/, "")
  end
  if (is_blog(url)) 
   url.sub!(/^\//, "")
   url.gsub!(/\//, "-")
  else
    url.sub!(/\/[^\/]*$/, "")
    url.sub!(/^\//, "")
    url.gsub!(/\//, "-")
  end
end

def normalize_text(text)
  unicode_ansc = {
    '&amp;' => '&',
    '&lt;' => '<',
    '&gt;' => '>',
    '&hellip;'=>'...',
    '&ldquo;' =>'"',
    '&rdquo;' =>'"',
    '&lsquo;' =>'\'',
    '&rsquo;' =>'\'',
    '&mdash;' =>'--',
    '&ndash;'=>'-'
  }
  utf8_ansc = {
    '&#8217;' => '\'',
    '&#151;' => '-'
  }

  unicode_ansc.each do |key, value|
    text.gsub!(key, value);
  end
  utf8_ansc.each do |key, value|
    text.gsub!(key, value);
  end

end

def parse(file_name)
  newfile = open(file_name).read
  normalize_text(newfile)

  print "File name: \t", file_name, "\n"
  doc = Hpricot(newfile)
  
  if doc.at("//meta[@name='Headline']").nil?
   if  doc.to_s =~ /^<meta name="Headline" content=([^>]*)>$/
        t=$1
        t.gsub!(/^\"/,"").gsub!(/\"$/,"").gsub!("\"","\\\"")
    end
  else
    t = doc.at("//meta[@name='Headline']").attributes["content"].strip
  end
  
  title=t
  puts title
   

  author= doc.at("//meta[@name='Byline']").attributes["content"].strip;
  date = doc.at("//meta[@name='Issue_Date']").attributes["content"].strip;
  blog_date=timetrans(date)
  puts author
  puts blog_date

  script=doc.at("/html/body").inner_html.to_s;
  if script =~ /article_url: "(.*)"/
    blog_url = $1
    b_url = $1
  end

  if author.empty?
    author = "anonymous"
  end
  print "********* ", blog_url," \n"

  blog_paragraph = doc.search("//div[@class='entry-body']/p")
  blog_content = ""
  links_array = []
  blog_paragraph.each do |para|
    next if para.inner_html.nil?
    doc_entry = Hpricot(para.inner_html.strip)
    links = doc_entry.search("[@href]").each do |link_entry|
      if link_entry.attributes["href"] != nil
        links_array << link_entry.attributes["href"]
      end
    end
    blog_content += para.inner_text.strip
  end
 
 
  quotes = doc.search("//div[@class='entry-body']/blockquote")
  quotes.each do |each_quote|
    next if each_quote.inner_html.nil?
    doc_entry = Hpricot(each_quote.inner_html.strip)
    links = doc_entry.search("[@href]").each do |link_entry|
      if link_entry.attributes["href"] != nil
        links_array << link_entry.attributes["href"]
      end
    end
    blog_content += each_quote.inner_text.strip
  end

  blog_content.gsub!("\"","\\\"")
  puts blog_content

  links_array.uniq!
  links_array.each do |each_link|
    puts each_link
  end
  
  article_id=get_article_id_by_url(b_url)
  prefix="http://nymag.com/comments/stories/"
  surfix="/comments/viewpost?page="
  script_url = prefix+article_id+surfix
  i = 1
  comments = []
  while(1)
    s_url=script_url+i.to_s
    print "script_url:\t", s_url, "\n"
    begin
    comm_page = Hpricot(open(s_url))
    rescue => e
      puts e
      break
    end
    flag = 0
    comm_page.search("//ul[@id='comment-list']/li").each do |comms|
      comm_entry = { }
      comm_entry[:content]=comms.at("/div").inner_text.gsub("\"", "\\\"").strip
      tmpauth=comms.at("/div[@class='info']/p[2]/i/a/cite").inner_text.strip
      if tmpauth.empty?
        tmpauth = "anonymous"
      end
      comm_entry[:user]=tmpauth
      tmpdate=comms.at("/div[@class='info']/p[2]/i").next.inner_text.gsub(/\s/,"").strip + comms.at("/div[@class='info']/p[2]/i").next.next.inner_text.strip
      comm_entry[:date]=timetrans(tmpdate)
      comments << comm_entry
      flag = 1
    end
    if(flag==1)
      i+=1
    else
      break
    end
  end 
        
  comments.each do |each_comment|
    puts each_comment[:user].strip
    puts each_comment[:date].strip
    puts each_comment[:content].strip

  end
  print "======================================\n"
  sql =<<-SQL
    select blog_id from blogs where blog_url = "#{blog_url}"
  SQL
  blog_exist = DBConnection::connection.select_all(sql)
  
  if blog_exist.empty?
    sql = <<-SQL
            insert into blogs (site_id, blog_id,blog_url,publish_date, author_name,content, title) 
            values ("3",null,"#{blog_url}","#{blog_date}","#{author}","#{blog_content}","#{title}")
    SQL
    DBConnection::connection.execute(sql)
    sql = <<-SQL
      select blog_id from blogs where blog_url = "#{blog_url}"
    SQL
    blog_id = DBConnection::connection.select_all(sql)[0]["blog_id"]

    print "blog_id ", blog_id, "\n"
    count = 0
    if !links_array.nil?
      links_array.each do |each_link|
        if each_link =~/^http:\/\/([^\/]*)\/.*/ and !each_link.include?("\"")
            l_domain = $1
            sql =<<-SQL
              select link_id from outlinks where link = "#{each_link}" and blog_id = "#{blog_id}"
            SQL
            link_exist = DBConnection::connection.select_all(sql)
            if link_exist.empty?
              sql =<<-SQL
              insert into outlinks(blog_id, link_id, link, link_domain)
              values("#{blog_id}",null, "#{each_link}","#{l_domain}")
              SQL
              DBConnection::connection.execute(sql)
              count += 1
            end
            l_domain=""
        end
      end
    end
    print count, "links are inserted\n"

    count = 0
    if !comments.nil?
      comments.each do |tmp|
        sql =<<-SQL
          insert into comments(blog_id, comment_id, author_name,publish_date,content)values("#{blog_id}",null,"#{tmp[:user]}","#{tmp[:date]}","#{tmp[:content]}")
        SQL
        DBConnection::connection.execute(sql)
        count += 1
      end
    end
    print count, "comments are inserted\n"
  end
end

def timetrans(orig)
  if orig =~ /on(\d+)\/(\d+)\/(\d+)at(\d+):(\d+)([ap]m)/ 
    tmpdate = $3+"-"+$1+"-"+$2;    
    t=$4;
    
    if $6 == "pm"
      if t.to_i < 12
        t = (t.to_i + 12).to_s
      end
    end
    tmptime= t +":"+$5+":"+"00"
    final=tmpdate+" "+tmptime
  else
    month_hash = {"January" => "01", "February"=> "02", "March" => "03", "April" => "04", "May" => "05", "June" => "06",
                  "July" => "07", "August" => "08", "September" => "09", "October" => "10", "November" => "11", "December"=> "12"}
    if orig =~ /(\w+)\s*(\d+),\s*(\d+)\s+(\d+):(\d+)\s*([AP]M)/
      tmptime = $3+"-"+month_hash[$1.strip]+"-"+$2;
      t = $4
      if($6=="PM")
        if t.to_i < 12
          t = (t.to_i + 12).to_s
        end
      end
      final=tmptime+" "+t+":"+$5+":"+"00"
    end
  end
end

line_array = []
prefix_hash = {1=>"f0000", 2=>"f000", 3=>"f00", 4=>"f0", 5=>"f"}

class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",                                                  
                                  :host => "ursa.rutgers.edu",
                                  :username => "root",                                                  
                                  :password => "",
                                  :database => "Weblog")



month_array=[1,2,3,4,5,6,7,8,9,10,11,12]
yearArray = [2006,2007,2008,2009]
nymag_prefix="http://nymag.com/daily/food/"
yearArray.each do |each_year|
  month_array.each do|each_month|
    if each_month <10
      month = "0" + each_month.to_s
    else
      month = each_month.to_s
    end
    dir_name = each_year.to_s+"-"+month
    midfix = each_year.to_s+"/"+month+"/"
    count = 0
    begin
    contains = Dir.new(dir_name).entries
    rescue => e
      puts e
      next
    end
    contains.each do |each_page|
    if each_page =~ /^[^.](.*)/
      if each_page =~ /(.*)\.\d$/
        next
      else
        page_path = dir_name+"/"+each_page
        parse(page_path)      
        count += 1
      end
    end
    end
    print month, " month", " has ", count, " posts\n"
  end
end
