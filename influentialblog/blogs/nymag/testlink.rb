require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'


newfile = open("http://nymag.com/daily/food/2007/10/three_versions_of_tailor_paul.html").read
doc = Hpricot(newfile)

blog_paragraph = doc.search("//div[@class='entry-body']/p")
  blog_content = ""
  links_array = []
  links = []
  blog_paragraph.each do |para|
    next if para.inner_html.nil?
    doc_entry = Hpricot(para.inner_html.strip)
    links = doc_entry.search("[@href]").each do |link_entry|
      puts link_entry
      if link_entry =~ /(.*)href=["\"]([^"\"]+)["\"].*/
        puts $2
        links << $2
      end
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
            puts link_entry
                  if link_entry =~ /(.*)href=["\"]([^"\"]+)["\"].*/
                            puts $2   
                            links << $2
                                  end

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
    if each_link.include?("\"")
      delete 
    else
    puts each_link
    end
  end
 puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  links.uniq!
  links.each do |each|
    puts each
  end

