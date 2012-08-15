require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl = "http://oneforkonespoon.blogspot.com/"


while 1
  
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
    break
  end
  doc.search("//div[@class='post hentry uncustomized-post-template']").each do | each_post|
    innerdoc = Hpricot(each_post.inner_html)
    url = innerdoc.at("/h3[@class='post-title entry-title']/a").attributes["href"]
    puts url
    url_file.puts(url)
  end

  nextpage = doc.at("//div[@class='blog-pager']/span[@id='blog-pager-older-link']/a")
  
  if !nextpage.nil?
    starturl=nextpage.attributes['href'].strip
    puts starturl
  else
    break
  end
end


