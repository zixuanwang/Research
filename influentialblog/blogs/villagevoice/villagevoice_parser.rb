require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'

class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",                                                  
                                  :host => "ursa.rutgers.edu",
                                  :username => "root",                                                  
                                  :password => "",
                                  :database => "Weblog")



module Normalize
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
end

#Here is the use of the Abstract Factory pattern
def blogparser_pipeline(factory)
  new_site = factory.new
  new_site.parse
  puts "created a new  #{new_site.class} with a factory"
end

module  TimeTrans
def timetrans(orig)
  
  month_hash = {"Jan"=>"01","Feb"=>"02","Mar"=>"03","Apr"=>"04",
                "May"=>"05","Jun"=>"06","Jul"=>"07","Aug"=>"08",
                "Sep"=>"09","Oct"=>"10","Nov"=>"11","Dec"=>"12"}

  if orig =~ /(\w+),\s+(\w+)\.\s+(\d+)\s+(\d+)\s+@\s+(\d+):(\d+)([AP]M)/
    date = $4+"-"+month_hash[$2]+"-"+$3
    tmp = 0
    if $7 == "PM" and $5.to_i < 12
      tmp = $5.to_i + 12
    else
      tmp = $5.to_i
    end
    time = tmp.to_s+":"+$6+":00"
    return_date = date+" "+time
  end
  return return_date
end #end of timetrans function
end

class VillageVoice
include TimeTrans
def parse
  year = [2008,2009]
  month = ["01","02","03","04","05","06","07","08","09","10","11","12"]
  log = File.open("villagevoice.log","w+")
  id = 0
  year.each do|each_year|
    month.each do |each_month|
      midix = each_year.to_s+"/"+each_month+"/"
      prefix = "http://blogs.villagevoice.com/forkintheroad/archives/"
      url = prefix+midix
      fix_url = url
      while 1
       # puts url
        begin
          doc = Hpricot(open(url))
        rescue => e
          break
          puts e
        end 
        if !doc.at("//div[@id='mainEntries']").nil?
          onePost = doc.search("//div[@id='mainEntries']/div[@class='entry']")
          onePost.each do|onep|
            id += 1
            inside_doc = Hpricot(onep.inner_html)
            getUrl = inside_doc.at("/h3/a").attributes['href']
            getTitle = inside_doc.at("/h3/a").inner_text
            getDate = timetrans(inside_doc.at("//div[@class='entryDate']").inner_text)
            getbyline = inside_doc.at("/div[@class='byLine']")
            if !getbyline.nil?
              second = getbyline.inner_text.strip.gsub(/in (.*)/, "")
              first = second.gsub(/By/,"")
              getAuthor = first.strip
            else
              getAuthor = "anonymous"
            end # end of if byline is not nil
            
            #puts getUrl 

            begin
              read_doc = Hpricot(open(getUrl)).to_s.gsub(/<p\/>/,"")
              real_doc = Hpricot(read_doc)
            rescue =>e
              break
              puts e
            end

            getlinks = []
            links =  real_doc.search("//div[@class='body']//a")
            if !links.nil?
              links.each do |each_l|
                #puts "has link"
                getlinks << each_l.attributes['href']
              end # end of getting links
            end
            
            content = []
            real_doc.search("//div[@class='body']/p").each do |each_p|
             # puts each_p
              if !each_p.empty? and !each_p.nil? 
                #puts "has content"
                content << each_p.inner_text.strip.gsub(/\s+/," ")
              end
            end # end of getting post content 
            
            real_doc.search("//div[@class='body']/blockquote").each do |each_p|
              if !each_p.empty? and !each_p.nil? 
               # puts "has content"
                content << each_p.inner_text.strip.gsub(/\s+/," ")
              end
            end # end of getting post content 

            real_doc.search("//div[@class='body']/div[@class='entryMoreText']/p").each do |each_p|
              if !each_p.empty? and !each_p.nil?
               #puts "Has more text!"
               content << each_p.inner_text.strip.gsub(/\s+/," ")
              end
             end # end of getting post content

            getpost = content.join(" ")
            getcomments_array =[]
            real_doc.search("//div[@class='footer']/div[@id='comments']/div[@class='listing']").each do|each_c|
              #puts "Has comment listing"  
              inside_comment = Hpricot(each_c.inner_html)
              temp_hash = Hash.new
              temp_hash['author']=inside_comment.at("/a/span").inner_text.strip
              temp_hash['date']=timetrans(inside_comment.at("/span[@class='commentDate']/a").inner_text.strip)
              comm_content_array =[]
              inside_comment.search("/p").each do |each_p|
                comm_content_array << each_p.inner_text.strip.gsub(/\s+/, " ")
              end
              temp_hash['content']=comm_content_array.join(" ")
              getcomments_array << temp_hash
            end # end for parsing each comment: listing

            real_doc.search("//div[@class='footer']/div[@id='comments']/div[@class='listing odd']").each do|each_c|
             # puts "Has comemnt listing odd"
              inside_comment = Hpricot(each_c.inner_html)
              temp_hash = Hash.new
              temp_hash['author']=inside_comment.at("/a/span").inner_text.strip
              temp_hash['date']=timetrans(inside_comment.at("/span[@class='commentDate']/a").inner_text.strip)
              comm_content_array=[]
              inside_comment.search("/p").each do |each_p|
                comm_content_array << each_p.inner_text.strip.gsub(/\s+/, " ")
              end
              temp_hash['content']=comm_content_array.join(" ")
              getcomments_array << temp_hash
            end #end for parsing each comment: listing odd

            
            log.puts("URL:\n#{getUrl}")
            log.puts("TITLE:\n#{getTitle}")
            log.puts("AUTHOR:\n#{getAuthor}")
            log.puts("DATE:\n#{getDate}")
            log.puts("POST:\n#{getpost}")
            log.puts("LINKS:")
            getlinks.each do |each_l|
              log.puts(each_l)
            end
            log.puts("COMMENTS:")
            if !getcomments_array.nil?
            getcomments_array.each do |each_c|
              log.puts("COMMENT AUTHOR\n#{each_c['author']}")
              log.puts("COMMENT DATE\n#{each_c['date']}")
              log.puts("COMMENT CONTENT\n#{each_c['content']}")
            end
            end # end of logging comemnts
        
            sql =<<-SQL
              select blog_id from blogs where blog_url = "#{getUrl}"
            SQL
            blog_exist = DBConnection::connection.select_all(sql)
    
            if blog_exist.empty?
              getTitle.gsub!(/\"/,"\\\"")
              getpost.gsub!(/\"/,"\\\"")
              getAuthor.gsub!(/\"/,"\\\"")
              sql = <<-SQL
              insert into blogs (site_id, blog_id,blog_url,publish_date, author_name,content, title) values ("7",null,"#{getUrl}","#{getDate}","#{getAuthor}","#{getpost}","#{getTitle}")
              SQL
              DBConnection::connection.execute(sql)
              sql = <<-SQL
                select blog_id from blogs where blog_url = "#{getUrl}"
              SQL
              blog_id = DBConnection::connection.select_all(sql)[0]["blog_id"]
      
              print "blog_id ", blog_id, "\n"
              if !getlinks.nil?
                getlinks.each do |each_link|
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
              end #end of if each link loop
            end # end of if getlinks.nil


            if !getcomments_array.nil?
              getcomments_array.each do |tmp|
                tmp['author'].gsub!(/\"/,"\\\"")
                tmp['content'].gsub!(/\"/,"\\\"")
                sql =<<-SQL
                  select comment_id from comments where blog_id = "#{blog_id}" and author_name = "#{tmp['author']}" and publish_date = "#{tmp['date']}" and content = "#{tmp['content']}" 
                SQL
                comment_exist = DBConnection::connection.select_all(sql)
             
                if !comment_exist.empty?
                  next
                else
                                  sql =<<-SQL
                  insert into comments(blog_id, comment_id, author_name,publish_date,content)values("#{blog_id}",null,"#{tmp['author']}","#{tmp['date']}","#{tmp['content']}")
                  SQL
                  DBConnection::connection.execute(sql)
                end
              end
            end
          end #end of database operation
        end # end of scanning each post in one page
        end #end of if has entry, end of parsing one blog post
        previous = doc.at("//div[@id='pagination']/div[@id='paginationNext']/a")
        if previous.nil?
          break
        else
          next_url = fix_url+previous.attributes['href'].strip
          url = next_url
        end
    end # end of while 1
 end #end of month 
end #end of year
  puts("#{id} posts have been processed!")
end #end of function
end #end of class

blogparser_pipeline(VillageVoice)



