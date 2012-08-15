require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl = "http://gothamist.com/food/"

while 1
  
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
    break
  end
  doc.search("div.adv_box").remove
  doc.search("//div#alpha-inner/div#section-header").remove
  doc.search("//div#alpha-inner/div[@id*='entry']").each do | each_post|
    url_part = each_post.at("/div.asset-header/h2/a")
    if url_part.nil?
      url_headless_part = each_post.at("/div[@class='asset-content entry-content']/span.headless_title/a")

      if url_headless_part.nil?
        puts "Can't find permanent link"
      else
        url = url_headless_part.attributes['href']
        puts url
        url_file.puts(url)
      end
    else
      url = url_part.attributes['href']
      puts url
      url_file.puts(url)
    end
  end

  nextpage = doc.at("//div[@class='content-nav']/div.previous/a")
  if !nextpage.nil?
    starturl=nextpage.attributes['href'].strip
    puts starturl
  else
    break
  end
end


