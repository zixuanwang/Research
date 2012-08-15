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
  def parse(in_url)
    url = in_url
    begin
    doc = Hpricot(open(in_url)) 
    rescue => e
      puts e
    end
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
    time =" "
    if byline.nil?
      puts "Can't find author and time"
    else
      b = byline.inner_text.strip
      puts b
      if b =~ /posted by (.*)at(.*)/
        author = $1.strip
        time = $2
      end
    end
    date = Time.parse(dd+time).strftime("%Y-%m-%d %H:%M:%S")
    puts url, author, date,title
  
    #get content
    doc.search("p[@class='postmetadata alt article-footer']").remove
    content = ""
    doc.search("//div[@class='entry article-text']//p").each do |each_para| 
      begin  
      content += each_para.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
    end
    content = content.gsub("\"","\\\"")
    puts content
    #get links
    linkarray = Array.new
    doc.search("//div[@class='entry article-text']//a").each do |each_link|
      if each_link.attributes['href'].nil?
        puts "Empty href"
      else
        linkarray << each_link.attributes['href']
        puts each_link.attributes['href']
      end
    end
    #get comments
    commentarray = Array.new
    doc.search("//div[@id='comments']/ol[@class='commentlist']/li").each do |each_c|
    c_doc = Hpricot(each_c.inner_html)
    commentHash = Hash.new 
    ca = c_doc.at("//div[@class='comment-author vcard']/cite[@class='fn']")
    if ca.nil?
      commentHash['author'] ="anonymous"
      puts "Can't find author"
    else
      commentHash['author']=ca.inner_text.strip
    end
    cd = c_doc.at("//div[@class='comment-meta commentmetadata']")
    if cd.nil?
      puts "Can't find comment date?"
      commentHash['date']=""
    else
      tcd = cd.inner_text.strip
      commentHash['date']=Time.parse(tcd).strftime("%Y-%m-%d %H:%M:%S")
    end
   
    cc=""
    c_doc.search("/div//p").each do |each_p|
      begin
        cc += each_p.inner_text.strip
      rescue Encoding::CompatibilityError => encoding
        puts encoding
        next
      end
    end
      commentHash['content'] = cc   
    end #end of comments.each
      
  end # end of parse function
  def main
    test_url = "http://www.foodmayhem.com/2009/04/day-dream.html"
    log_file=File.open("foodmayhem.log", "a+")
    parse(test_url)
  end # end of main function
end #end of class

blogparser_pipeline(Foodmayhem)
