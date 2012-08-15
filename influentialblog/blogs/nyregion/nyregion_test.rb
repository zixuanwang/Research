require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'

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
  #'&#228;' => 'ä' ,
  #'&#246;' => 'ö',
  #'&#220;' => 'Ü',
  #'&#252;' => 'ü',
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
end

def timetrans(orig)
  orig.gsub!(" ","")
  month_hash = {"January" => "01", "February"=> "02", "March" => "03", "April" => "04", "May" => "05", "June" => "06",
                  "July" => "07", "August" => "08", "September" => "09", "October" => "10", "November" => "11", "December"=> "12"}
  if orig =~ /([^\d]+)(\d+),(\d+)/ 
      final=$3+"-"+month_hash[$1]+"-"+$2+" "+"00:00:00"
  end
  return final
end

def parse(file_name)
  begin
  file_text = Hpricot(open(file_name)).to_s
  normalize_text(file_text)
  doc = Hpricot(file_text)
  rescue =>e
    puts e
  end
  wholepage = file_text 

  #get URL
  if wholepage =~ /function getShareURL([^\{]*)\{([^\}]*)\}/
    inside =$2
    inside = inside.strip
    if inside =~ /return encodeURIComponent\('([^']*)'\)/
      url = $1
    end
  end

  if url.nil?
    urll = doc.at("//input[@name='url']")
    if !urll.nil?
      url = urll.attributes["value"]
      normalize_url(url)
    end
  end

    
  #get title
  if wholepage =~ /function getShareHeadline([^\{]*)\{([^\}]*)\}/
    inside =$2
    #print "title inside ", inside, "\n"
    inside = inside.strip
    if inside =~ /return encodeURIComponent\('(.*)'\)/
      t = $1
    end
  end
  title=t.strip

  #get author
  a = doc.at("//nyt_byline/div[@class='byline']/a")
  if a.nil?
    aa = doc.at("//div[@class='byline']")
    if aa.nil?
    puts "can't find author!!!"
    else
      author = aa.inner_text.strip
      if author =~ /^By (.*)/
        author = $1
      end
    end
  else
    author = a.inner_text.strip
  end
  
  if author.nil?
    author = "anonymous"
  end

  #get Date
  d = doc.search("//div[@class='timestamp']")
  if d.nil?
    puts "can't find timestamp!!!"
  else
    date = d.inner_text.strip
    blog_date = date
    if date =~ /Published: (.*)/
      blog_date = $1
    end
  end
  blog_date = timetrans(blog_date)

  #get content

  links = Array.new
  content = ""

  #keep inline box in order to keep related links
  #doc.search("div[@id='inlineBox']").remove
  
  c = doc.search("//div[@id='articleBody']")
  if c.nil?
    puts "can't find Content!!!"
  else
    para = Hpricot(c.inner_html)
    para.search("script").remove
    para.search("style").remove
   
    para.search("//a").each do |each_a|
      if !each_a.attributes["href"].nil?
        links << each_a.attributes["href"].strip
      end
    end
    
    para.search("//p").each do |each_p|
      if !each_p.nil?
        content += each_p.inner_text.strip
      end
    end
  end
  
  next_page = doc.search("//div[@id='articleBody']//div[@id='pageLinks']/ul[@id='pageNumbers']")
  if !next_page.nil?
    begin
      page_number = Hpricot(next_page.inner_html)
    rescue Exception => e
      puts e
    end
    prefix = "http://www.nytimes.com/"
    page_number.search("//li/a").each do |next_number|
      next_url = next_number.attributes["href"].strip
      next_url = prefix+next_url
      print "next page: ", next_url, "\n"
      file_temp = Hpricot(open(next_url)).to_s
      normalize_text(file_temp)
      next_doc = Hpricot(file_temp)
      
      next_doc.search("script").remove
      next_doc.search("style").remove
      # Keep inline Box, because it provides many related links.
      #next_doc.search("div[@id='inlineBox']").remove
      puts next_doc.at("//div[@id='articleBody']").inner_html
      
      next_doc.search("//div[@id='articleBody']//p//a").each do |link_entry|
        if !link_entry.attributes["href"].nil?
          puts link_entry.attributes["href"].strip
          links << link_entry.attributes["href"].strip
        end
      end
      
      next_para = next_doc.search("//div[@id='articleBody']//p")
      if next_para.nil?
        puts "no content in temp!!!"
      else
        next_para.each do |p|
          if !p.inner_text.strip.nil? and !p.inner_text.strip.empty? 
              p_content = p.inner_text.strip
              puts p_content
              content += p_content
            end
          end
      end
    end
  end
 
  if !content.nil? and !content.empty?
    normalize_text(content)
    content = content.gsub('"','\"').gsub(/\s+/," ").gsub(/<92>/, "'")
  end

  puts("URL:")
  puts(url)
  puts("Title:")
  puts(title)
  puts("Author:")
  puts(author)
  puts("Date:")
  puts(blog_date)
  puts("Content:")
  puts(content)
  puts("Links:")
  links.uniq!
  links.each do |l|
    if l =~ /^http:\/\/(.*)/
      puts(l)
    else
      links.delete(l)
    end
  end
  
 return
  sql =<<-SQL
    select blog_id from blogs where blog_url = "#{url}"
  SQL
  blog_exist = DBConnection::connection.select_all(sql)
  if !blog_exist.empty?
    sql = <<-SQL
      update blogs set site_id = 5 where blog_url = "#{url}"
    SQL
    DBConnection::connection.execute(sql)
    sql = <<-SQL
      update blogs set content ="#{content}"  where blog_url = "#{url}"
    SQL
    DBConnection::connection.execute(sql)
  else
    sql = <<-SQL
            insert into blogs (site_id, blog_id,blog_url,publish_date, author_name,content, title) 
            values ("5",null,"#{url}","#{blog_date}","#{author}","#{content}","#{title}")
    SQL
    DBConnection::connection.execute(sql)

    sql = <<-SQL
      select blog_id from blogs where blog_url = "#{url}"
    SQL
    blog_id = DBConnection::connection.select_all(sql)[0]["blog_id"]
    
    links.each do |each_link|
      if each_link =~/^http:\/\/([^\/]*)\/.*/
        l_domain = $1
        sql =<<-SQL
          select link_id from outlinks where link = "#{each_link}"
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

end


class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",       
                                  :host => "ursa.rutgers.edu",
                                  :username => "root",       
                                  :password => "",
                                  :database => "Weblog")


parse("http://www.nytimes.com/2007/04/01/nyregion/nyregionspecial2/01Rdinner.html?pagewanted=1&_r=1")
