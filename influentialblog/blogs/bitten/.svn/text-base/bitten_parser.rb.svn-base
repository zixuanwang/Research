require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'

Hpricot.buffer_size = 262144
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
    '&#151;' => '-',
    '&#8212' => ''
  }
 
    iso_ansc = {
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
    '&#228;' => 'ä' ,
    '&#246;' => 'ö',
    '&#220;' => 'Ü',
    '&#252;' => 'ü',
    '&#147;' => '"',
    '&#148;' => '"',
    '&#063;' => '?',
    '&#038;' => '&',
    '&#x00bb;'=>'',
    '&#39;' => '\''
 }

  unicode_ansc.each do |key, value|
    text.gsub!(key, value)
  end
  utf8_ansc.each do |key, value|
    text.gsub!(key, value)
  end
  iso_ansc.each do |key, value|
    text.gsub!(key, value)
  end
end

def getcomments( doc )
  comm_array = Array.new
  doc.search("//div[@id='comments']/ol/li").each do |comment_entry|
    comm_hash = Hash.new
    comment_date = comment_entry.at("//div[@class='comment-meta']/span[@class='updated']")
      comm_hash[:date] = timetrans(comment_date.inner_text.strip.gsub!("Link",""))
      content = ""
      if comment_entry.search("//div[@class='comment-content']/p").nil?
        puts "No comment content!!"
      else
        comment_entry.search("//div[@class='comment-content']/p").each do |para|
        if !para.nil?
          content +=  "#{para.inner_text}"
        end
      end
      end
      comm_hash[:content] = content.gsub('"','\"')
      normalize_text(comm_hash[:content])
      author = comment_entry.at("//div[@class='comment-content']/cite")
      if author.nil?
        comm_hash[:author] = "anonymous"
      else
        comm_hash[:author] = author.inner_text.gsub("—","").gsub(";","").gsub("\\","").gsub('"','\"').strip
      end
   comm_array << comm_hash
  end
  return comm_array
end

def parse(file_name)
  print "File name: \t", file_name, "\n"
  transcmd = "dos2unix \""+file_name +"\""
  system(transcmd)
  newfile = open(file_name).read
  normalize_text(newfile)
  doc = Hpricot(newfile)

  #get title
  if doc.at("//head/title").nil?
    puts "Can't find title!!!"
  else
    t = doc.at("//head/title").inner_text.strip
    if t =~ /(.*) - NYTimes.com$/
      title = $1
    else
      title = t
    end
    if title =~ /(.*) - Bitten Blog/
      title = $1
    end
  end
  title.gsub!('"','\"')

  #get url and author
  if doc.at("//div[@class='entry-meta']/ul[@class='entry-tools']/li/form/input[@name='url']").nil?
    puts "can't find url!!"
  else
    url = doc.at("//div[@class='entry-meta']/ul/li/form/input[@name='url']").attributes["value"].strip
  end
  if doc.at("//div[@class='entry-meta']/ul/li/form/input[@name='author']").nil?
    puts "can't find author!!"
  else
    author = doc.at("//div[@class='entry-meta']/ul/li/form/input[@name='author']").attributes["value"].strip
  end
  normalize_url(url)
  normalize_url(author)
  if author =~ /By (.*)/
    author = $1
  end
  author.gsub!('"','\"')

  #get date
  date = doc.at("//span[@class='date']").inner_text.strip;
  blog_date=timetrans(date)

  #get post and links
  links = Array.new
  link_hash = Hash.new
  post_hash = Hash.new
  doc.search("script").remove
  doc.search("style").remove

  content = doc.at("//div[@class='entry-content']");
  post_content = ""
  if !content.nil?
    post_content = content.inner_text.gsub('"','\"').gsub(/\s+/," ").strip
  end

  post=doc.at("//div[@class='entry-content']").inner_html.strip;
  Hpricot(post).search("//a").each do |link_entry|
    if link_entry.attributes["href"] != nil
      if link_entry.attributes["href"] =~ /^http:\/\/(.*)/
        links << link_entry.attributes["href"]
      else
        puts "abnormal links!!!"
      end
    end
  end

 
  #get comments
  comments = Array.new
  comments += getcomments(doc)
  prefix = "http://bitten.blogs.nytimes.com/"
  if !doc.search("//div[@id='comments']/div[@class='pages']").nil?
    next_comments = doc.search("//div[@id='comments']/div[@class='pages']/a[@class='page-numbers']")
    next_comments.each do |next_entry|
     comment_url = prefix + next_entry.attributes["href"]
     next_doc = Hpricot(open(comment_url))
     comments += getcomments(next_doc) 
    end
  end

  log=open("/ursa/local/jinyun/bitten/pagelog", "a+")
  log.puts("URL:")
  log.puts(url)
  log.puts("Title:")
  log.puts(title)
  log.puts("Author:")
  log.puts(author)
  log.puts("Date:")
  log.puts(blog_date)
  log.puts("Post:")
  log.puts(post_content)
  log.puts("Links:")
  links.each do |each_link|
      log.puts(each_link)
  end

  comments.each do |comh|
    log.puts("Commenter:")
    log.puts(comh[:author])
    log.puts("Comment Date:")
    log.puts(comh[:date])
    log.puts("Comment content:")
    log.puts(comh[:content])
  end
  log.puts("\n")
  log.close
  
  sql =<<-SQL
    select blog_id from blogs where blog_url = "#{url}"
  SQL
  blog_exist = DBConnection::connection.select_all(sql)
  if blog_exist.empty?
    sql = <<-SQL
            insert into blogs (site_id, blog_id,blog_url,publish_date, author_name,content, title) 
            values ("6",null,"#{url}","#{blog_date}","#{author}","#{post_content}","#{title}")
    SQL
    DBConnection::connection.execute(sql)
    sql = <<-SQL
      select blog_id from blogs where blog_url = "#{url}"
    SQL
    blog_id = DBConnection::connection.select_all(sql)[0]["blog_id"]
    
    if !links.nil?
      links.each do |each_link|
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
            end
            l_domain=""
        end
      end
    end

    count = 0
    if !comments.nil?
      comments.each do |tmp|
        sql =<<-SQL
          insert into comments(blog_id, comment_id, author_name,publish_date,content) values("#{blog_id}",null,"#{tmp[:author]}","#{tmp[:date]}","#{tmp[:content]}")
        SQL
        DBConnection::connection.execute(sql)
        count += 1
      end
    end
    print count, "comments are inserted\n"
  end
end

def timetrans(orig)
  month_hash = {"January" => "01", "February"=> "02", "March" => "03", "April" => "04", "May" => "05", "June" => "06",
                      "July" => "07", "August" => "08", "September" => "09", "October" => "10", "November" => "11", "December"=> "12"}
 
  orig.gsub!(" ","")
  orig.gsub!(/<[^>]*>/,"")
  if orig =~ /(.*),(\d\d\d\d)(\d+:\d+)([ap]m)/
    orig = $1+","+$2+","+$3+$4
  end
  if orig =~ /([^\d]+)(\d+),(\d+),(\d+):(\d+)([ap]m)/ 
    tmpdate = $3+"-"+month_hash[$1]+"-"+$2;    
    t=$4;
    if $6 == "pm"
      if t.to_i < 12
        t = (t.to_i + 12).to_s
      end
    end
    tmptime= t +":"+$5+":"+"00"
    final=tmpdate+" "+tmptime
  end
end

prefix_hash = {1=>"f0000", 2=>"f000", 3=>"f00", 4=>"f0", 5=>"f"}

class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",                                                  
                                  :host => "ursa.rutgers.edu",
                                  :username => "root",                                                  
                                  :password => "",
                                  :database => "Weblog")



month_array=[1,2,3,4,5,6,7,8,9,10,11,12]
yearArray = [2007,2008,2009]
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
      if each_page =~ /\d+/
       page = dir_name + "/" + each_page
       parse(page)      
        count += 1
      end
    end
    print each_month, " month", " has ", count, " posts\n"
  end
end
