require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl = "http://eastofnyc.typepad.com/"

while 1
  
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
    break
  end
  doc.search("//div[@id='beta-inner']/div.entry").each do | each_post|
    url = each_post.at("/h3[@class='entry-header']/a").attributes["href"]
    puts url
    url_file.puts(url)
  end

  nextpage = doc.at("//div[@class='pager-bottom pager-entries pager content-nav']/div.pager-inner/span.pager-right/a")
  if !nextpage.nil?
    starturl=nextpage.attributes['href'].strip
    puts starturl
  else
    break
  end
end


