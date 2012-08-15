require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'
require 'time'

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
end # end of module
 
#Here is the use of the Abstract Factory pattern
def blogparser_pipeline(factory)
  new_site = factory.new
  new_site.main
  puts "created a new  #{new_site.class} with a factory"
end

class Eatsblog
  include Normalize
  def parse(post_url)
    begin
      doc=Hpricot(open(post_url))
    rescue => e
      puts e 
      return -1
    end
    
    #get url
    url = post_url
    puts url
    #get title
    t = doc.at("//div[@class='entry']/h3[@class='entry-header']/a")
    if t.nil?
      puts "Can't find title"
    else
      title = t.inner_text
    end
    puts  title
    #get author
    a = doc.at("//span[@class='authorname']")
    if a.nil? 
      puts "Can't find author"
      author = "anonymous"
    else
      author = a.inner_text
    end
    puts author
    #get timestamp
    t = doc.at("//table[@id='blog-body-heading']/tr/td/table/tr[2]/td")
    d_text=""
    if  t.nil?
      puts "Can't find time"
    else
      if t.inner_text.strip.empty? or t.inner_text.nil?
        puts "td empty!"
        t2 = doc.at("//table[@id='blog-body-heading']/tr/td/table/tr[2]/td[2]")
        if t2.nil? or t2.empty?
          puts "Can't find td[2]!"
        else 
          d_text = t2.inner_text.strip
        end
      else
        puts "td1 not empty"
        d_text = t.inner_text.strip
      end
      if d_text.strip =~ /([^|]+)|(.*)/
        tstamp = $1
        date  =  Time.parse(tstamp).strftime("%Y-%m-%d %H:%M:%S")
      end
    end
    puts date
    #get content
    content = ""
    doc.search("//div[@id='blog-body']//p").each do |para|
     content += para.inner_text.strip
    end
    puts "CONTENT"
    puts content
    #get links
    linkarray = Array.new
    doc.search("//div[@id='blog-body']//p//a").each do |each_l|
      if each_l.attributes['href'].nil?
        puts "Empty <a>?"
      else
        linkarray << each_l.attributes['href']
      end
    end
    puts "LINKS"
    linkarray.uniq.each do |each_l|
      puts each_l
    end
    #get comments
    comment_array=Array.new
    doc.search("//div[@id='comments']/div[@class='comments-content']/div[@class='comment']/div[@class='inner']").each do |each_c|
      if each_c.inner_html.empty?
        puts "Empty comments?"
      else
        in_comment = Hpricot(each_c.inner_html)
        single_comment = Hash.new
        byline = in_comment.at("/div[@class='comment-header']/span[@class='byline']")
        if  byline.nil?
          puts "can't find comment byline"
        else
          byline = byline.inner_text.strip
          if byline=~/Posted by ([^@]+)@(.*)/
            single_comment['author'] = $1.strip
            single_comment['date'] = Time.parse($2.strip).strftime("%Y-%m-%d %H:%M:%S")
          end
        end # end if byline.nil?
        single_comment['content'] = in_comment.at("//div[@class='comment-content']").inner_text.strip
      end #end if each_c.inner_html.empty?
     comment_array << single_comment 
    end #end of get  comments
    puts "COMMENTS:"
    comment_array.each do |each_c|
      puts each_c['author']
      puts each_c['date']
      puts each_c['content']
    end
  end # end of parse function
  
  def main
    test_url = "http://eatsblog.guidelive.com/archives/2007/06/you-know-you-want-it.html"
    parse(test_url)
  end # end of main function
end #end of class

blogparser_pipeline(Eatsblog)
