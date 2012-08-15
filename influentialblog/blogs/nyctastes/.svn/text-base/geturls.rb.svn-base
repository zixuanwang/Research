require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl = "http://nyctastes.blogspot.com/"


while 1
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
    break
  end
  doc.search("//div[@class='blog-posts hfeed']/div[@class='post hentry']").each do | each_post|
    innerdoc = Hpricot(each_post.inner_html)
    urlsection = innerdoc.at("/h3[@class='post-title entry-title']/a")
    if urlsection.nil?
      puts "Wrong format of post"
    else
      url = urlsection.attributes["href"]
      puts url
      url_file.puts(url)
    end
  end

  nextpage = doc.at("//div[@class='blog-pager']/span[@id='blog-pager-older-link']/a")
  
  if !nextpage.nil?
    starturl=nextpage.attributes['href'].strip
    puts starturl
  else
    break
  end
end


