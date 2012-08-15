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
  file_text = open(file_name).read
  normalize_text(file_text)
  doc = Hpricot(file_text)
  individual_post = doc.at("//div[@class='individualPost']")
  comments_post = doc.at("//div[@id='comments']")

  post_doc = Hpricot(individual_post.inner_html)
  comments_doc = Hpricot(comments_post.inner_html)

#  print "comments_doc================\n", comments_doc

  title = post_doc.at("//h3").inner_text.strip;
  if title =~/([^|]+)| Serious Eats/
  title.gsub("| Serious Eats", "")
  end
  puts title
  byline = post_doc.at("//p[@class='byline']");

  if byline.inner_text =~ /Posted by\s*([^,]+),\s*(.*)/
    author = $1
    blog_date = $2
  end
  puts author
  puts timetrans(blog_date)
  
  blog_content = ""
  links_array = []
  blog_paragraph = byline.next
  while(1)
    if blog_paragraph.to_s =~ /postFooter/
      break
    else
      if !blog_paragraph.inner_text.strip.empty?
        p_entry =  Hpricot(blog_paragraph.inner_html.strip)
        p_entry.search("[@href]").each do |link_entry|
          if link_entry.attributes["href"] != nil
            links_array << link_entry.attributes["href"]
          end
        end
        blog_content += blog_paragraph.inner_text.strip;
      end
      blog_paragraph = blog_paragraph.next
    end
  end
  
  blog_content.gsub!("\"","\\\"")
  puts blog_content
  links_array.each do |each_l|
    puts each_l
  end
  
  comments_array = []
  comments_doc.search("/div").each do |each_c|
    comment_entry = {}  
    comment_entry[:content] = Hpricot(each_c.inner_html.strip).at("//div[@class='comment-body']").inner_text.strip.gsub("\"","\\\"")
    auth_date = Hpricot(each_c.inner_html.strip).at("//p[@class='commenter postFooter]").inner_text.strip
    if auth_date =~ /(.*)\sat\s*(.*)/
        comment_entry[:user]=$1
        tmpd=$2
        comment_entry[:date]=timetrans(tmpd)
    end
    puts comment_entry[:content]
    puts comment_entry[:user]
    puts comment_entry[:date]
    puts "==========================="
    comments_array << comment_entry
  end
  
  sql =<<-SQL
    select blog_id from blogs where blog_url = "#{url}"
  SQL
  blog_exist = DBConnection::connection.select_all(sql)
  if blog_exist.empty?
    sql = <<-SQL
            insert into blogs (site_id, blog_id,blog_url,publish_date, author_name,content, title) 
            values ("1",null,"#{url}","#{blog_date}","#{author}","#{blog_content}","#{title}")
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
  if orig =~ /(\d+):(\d+)([AP]M)\s*on\s*(\d+)\/(\d+)\/(\d+)/ 
    tmpdate = "20"+$6+"-"+$4+"-"+$5;    
    t=$1;
    
    if $3 == "PM"
      if t.to_i < 12
        t = (t.to_i + 12).to_s
      end
    end
    tmptime= t +":"+$2+":"+"00"
    final=tmpdate+" "+tmptime
  else
    month_hash = {"January" => "01", "February"=> "02", "March" => "03", "April" => "04", "May" => "05", "June" => "06",
                  "July" => "07", "August" => "08", "September" => "09", "October" => "10", "November" => "11", "December"=> "12"}
    if orig =~ /(\w+)\s*(\d+),\s*(\d+)\s*at\s*(\d+):(\d+)\s*([AP]M)/
      tmpdate=$3+"-"+month_hash[$1.strip]+"-"+$2+" "
      t = $4
      if $6 == "PM"
         if t.to_i < 12
             t = (t.to_i + 12).to_s
         end
     end
      final=tmpdate+t+":"+$5+":00"
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

File.open("indexFinal").each do |line|
  line_array = line.strip.split(/ /)
  tmp_file_name = prefix_hash[line_array[0].length]+line_array[0]
  print tmp_file_name,"\t", line_array[1],"\n"
  parse(tmp_file_name, line_array[1])
end


