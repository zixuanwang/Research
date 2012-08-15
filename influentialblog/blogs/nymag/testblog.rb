 
require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'
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

url = "http://nymag.com/daily/food/2008/11/suggested_google_searches_anth.html"
newfile = open(url).read
normalize_text(newfile)

doc = Hpricot(newfile)
 
if doc.at("//meta[@name='Headline']").nil?
  if  doc.to_s =~ /^<meta name="Headline" content=([^>]*)>$/
      t=$1
      puts t
      t.gsub!(/^\"/,"").gsub!(/\"$/,"").gsub!("\"","\\\"")
      puts t
  end
else
  t = title.attributes["content"].strip
end


author= doc.at("//meta[@name='Byline']").attributes["content"].strip;
  date = doc.at("//meta[@name='Issue_Date']").attributes["content"].strip;
  puts author
  puts date

  print "===================\n"
  
return
  blog_paragraph = doc.search("//div[@class='entry-body']/p")
  blog_content = ""
  links_array = []
  

  blog_paragraph.each do |para|
    puts para
    if para.inner_html.nil?
      next
    else
    doc_entry = Hpricot(para.inner_html.strip)
    links = doc_entry.search("[@href]").each do |link_entry|
      if link_entry.attributes["href"] != nil
        links_array << link_entry.attributes["href"]
      end
    end
    blog_content += para.inner_text.strip
  end
  end

  blog_content.gsub!("\"","\\\"")
  puts blog_content

  links_array.each do |each_link|
    puts each_link
  end
  

