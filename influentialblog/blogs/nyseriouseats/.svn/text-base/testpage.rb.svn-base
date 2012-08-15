require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'


  file_text = open("http://newyork.seriouseats.com/2006/08/top-ten-fancypants-burgers-in.html").read
  
  doc = Hpricot(file_text)
   individual_post = doc.at("//div[@class='individualPost']")
  comments_post = doc.at("//div[@id='comments']")

  post_doc = Hpricot(individual_post.inner_html)
  comments_doc = Hpricot(comments_post.inner_html)

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

  blog_content = ""
  links_array = []
  blog_paragraph = byline.next
  while(1)
    if blog_paragraph.to_s =~ /postFooter/
      break
    else
      puts blog_paragraph.inner_html
      puts "====================================="
      
      blog_content += blog_paragraph.inner_text.strip;
      if !blog_paragraph.inner_html.nil? and !blog_paragraph.inner_text.strip.empty?
        p_entry =  Hpricot(blog_paragraph.inner_html.strip)
        p_entry.search("[@href]").each do |link_entry|
          if link_entry.attributes["href"] != nil
            links_array << link_entry.attributes["href"]
          end
        end
      end
      blog_paragraph = blog_paragraph.next
    end
  end
  
  blog_content.gsub!("\"","\\\"")
  puts blog_content

