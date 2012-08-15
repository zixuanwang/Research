require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'

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
  '&#150;'  => '-' }
 unicode_ansc.each do |key, value|
   text.gsub!(key, value)
 end
end

def parse(file_name, url)
  print file_name;
  print url;
  file_text = open(file_name).read
  normalize_text(file_text)
  doc = Hpricot(file_text)
  title = (doc/"/html/body/div/div[4]/div/span").inner_html.strip;
  puts title;
  author = doc.at("/html/body/div/div[4]/div/br").next;
  while (1)
    if author.to_s.strip =~ /(.*)(200)\d/
      if author.to_s.strip =~ /by/
        if author.to_s.strip =~ /(.*),\s*by\s*(.*)/
          blog_date=timetrans($1.strip)
          blog_author=$2;
        end
      else
        blog_date=timetrans(author.inner_text.strip)
        blog_author="anonymous"
      end
    break
    else 
      author=author.next
    end
  end
  
  puts blog_date, blog_author 

  blog_paragraph = doc.search("//div[@id='column1']/p")

  blog_content = ""
  links_array = []
  blog_paragraph.each do |para|
    if !para.inner_html.nil?
      doc_entry = Hpricot(para.inner_html.strip)
      links = doc_entry.search("[@href]").each do |link_entry|
        if link_entry.attributes["href"] != nil
          links_array << link_entry.attributes["href"]
        end
      end
    blog_content += para.inner_text.strip
    end
  end
 
  blog_quotes = doc.search("//div[@id='column1']/blockquote")

  blog_quotes.each do |quote|
    if !quote.inner_html.nil?
      doc_entry = Hpricot(quote.inner_html.strip)
      links = doc_entry.search("[@href]").each do |link_entry|
        if link_entry.attributes["href"] != nil
          links_array << link_entry.attributes["href"]
        end
      end
    blog_content += quote.inner_text.strip
    end
  end

  blog_content.gsub!("\"","\\\"")
  puts blog_content
  
  links_array.each do |each_link|
    puts each_link
  end
   
  script_url = ""
  doc.search("/html/body/div/div[4]/div/script").each do |script|
    if script.attributes['src'] =~ /comments\.js/
        script_url = script.attributes['src']
    end
  end
  
  if !script_url.empty?
    comments = Hpricot(open(script_url)).to_s;
    comments = comments[comments.index("\\")  ... comments.rindex("\"")].gsub("\\u003C", "<").gsub("\\u003E", ">")
    comments.gsub!("\\\"","\"");
    comments.gsub!("\\n", "");
    comments.gsub!("\\t", "");

    comments_array = []
    comment_html = Hpricot(comments);
    comment_html.search("//div[@class='comment ']").each do |comment_entry|
      comments_array_entry = {}
      comments_array_entry[:content] = comment_entry.at("//div[@class='comment-body']/p").inner_text.gsub("\"","\\\"")
      comments_array_entry[:user] = comment_entry.at("//div[@class='comment-who']/a").attributes["alt"];
      comments_array_entry[:date] = timetrans(comment_entry.search("//div[@class='comment-when']/a")[1].inner_text);
      comments_array << comments_array_entry;
    end
  end
  
  sql =<<-SQL
    select blog_id from blogs where blog_url = "#{url}"
  SQL
  blog_exist = DBConnection::connection.select_all(sql)
  if blog_exist.empty?
    sql = <<-SQL
            insert into blogs (site_id, blog_id,blog_url,publish_date, author_name,content, title) 
            values ("2",null,"#{url}","#{blog_date}","#{blog_author}","#{blog_content}","#{title}")
    SQL
    DBConnection::connection.execute(sql)

    sql = <<-SQL
      select blog_id from blogs where blog_url = "#{url}"
    SQL
    blog_id = DBConnection::connection.select_all(sql)[0]["blog_id"]
    puts blog_id
    
    links_array.each do |each_link|
      puts each_link
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

    if !comments_array.nil?
      comments_array.each do |tmp|
        sql =<<-SQL
          insert into comments(blog_id, comment_id, author_name,publish_date,content)
          values("#{blog_id}",null,"#{tmp[:user]}","#{tmp[:date]}","#{tmp[:content]}")
        SQL
        DBConnection::connection.execute(sql)
      end
    end
  end
end


def timetrans(orig)
  if orig =~ /(\d+)\/(\d+)\/(\d+) (\d+):(\d+) ([AP]M)/ 
    tmpdate = "20"+$3+"-"+$1+"-"+$2;    
    t=$4;
    
    if $6 == "PM"
      if t.to_i < 12
        t = (t.to_i + 12).to_s
      end
    end
    tmptime= t +":"+$5+":"+"00"
    final=tmpdate+" "+tmptime
  else
    month_hash = {"January" => "01", "February"=> "02", "March" => "03", "April" => "04", "May" => "05", "June" => "06",
                  "July" => "07", "August" => "08", "September" => "09", "October" => "10", "November" => "11", "December"=> "12"}
    if orig =~ /(.*), (.*)\s+(\d+), (\d+)/
      final=$4+"-"+month_hash[$2.strip]+"-"+$3+" "+"00:00:00"
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

File.open("testURL").each do |line|
  line_array = line.strip.split(/ /)
  tmp_file_name = prefix_hash[line_array[0].length]+line_array[0]
  parse(tmp_file_name, line_array[1])
end


