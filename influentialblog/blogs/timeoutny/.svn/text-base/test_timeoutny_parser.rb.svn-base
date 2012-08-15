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

class Timeoutny
  include Normalize
  def parse(in_url)
    url = in_url
    begin
      wholefile = Hpricot(open(in_url)).to_s
      normalize_text(wholefile)
      doc = Hpricot(wholefile) 
    rescue => e
      puts e
    end
    #get title
    t = doc.at("//div[@class='post LY_clear']/h2/a")
    if t.nil?
      puts "Can't find title"
    else
      title = t.inner_text.strip.gsub("\"","\\\"")
    end
    #get date and author
    d = doc.at("//div[@class='wp-byline']")
    if d.nil?
      puts "Can't find byline"
    else
      dd = d.inner_text.strip
      if dd =~ /.*by(.*)on(.*)/
        author = $1.strip
        in_date = $2.strip
      end
    end
  
    date = Time.parse(in_date).strftime("%Y-%m-%d %H:%M:%S")
    puts url, author, date,title
     
    #get content
    content = ""
    doc.search("//div[@class='entry']//p").each do |each_para| 
      begin  
      content += each_para.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
    end
    content = content.gsub("\"","\\\"")
    puts ("**************************")
    puts content
    #get links
    linkarray = Array.new
    doc.search("//div[@class='entry']//a").each do |each_link|
      if each_link.attributes['href'].nil?
        puts "Empty href"
      else
        linkarray << each_link.attributes['href']
        puts each_link.attributes['href']
      end
    end
    #get comments
    commentarray = Array.new
    doc.search("//ol[@class='comments']/li[@class='comment']").each do |each_c|
    c_doc = Hpricot(each_c.inner_html)
    commentHash = Hash.new 
    ca = c_doc.at("//div[@class='comment-byline']")
    if ca.nil?
      commentHash['author'] ="anonymous"
      puts "Can't find author and date"
    else
      cad = ca.inner_text.strip
      puts cad
      if cad =~ /Posted by(.*)on(.*)/
        commentHash['author']=$1.strip
        cdt = $2.strip
        commentHash['date'] = Time.parse(cdt).strftime("%Y-%m-%d %H:%M:%S")
      end
    end  
    cc=""
    c_doc.search("//p").each do |each_p|
      begin
        cc += each_p.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
    end # end of comment p
    commentHash['content'] = cc.gsub("\"","\\\"")  
    commentarray<<commentHash
    
    end #end of comments.each
    puts "**************COMMENTS**************"
    commentarray.each do|each_c|
      puts each_c["author"]
      puts each_c["date"]
      puts each_c["content"]
    end
  end # end of parse function
  
  def main
    test_url = "http://www3.timeoutny.com/newyork/the-feed-blog/restaurants-bars/2007/07/smells-fishy/"
    #test_url = "http://www3.timeoutny.com/newyork/the-feed-blog/restaurants-bars/2008/11/whiskyfest-2008-the-aftermath/"
    log_file=File.open("timeoutny.log", "a+")
    parse(test_url)
  end # end of main function
end #end of class

blogparser_pipeline(Timeoutny)
