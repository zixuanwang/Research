require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl="http://blog.city-eating.com/"
while 1
  
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
    break
  end
  doc.search("//div.entry").each do | each_post|
    url_part = each_post.at("/h3.entry-header/a")
    if url_part.nil?
      puts "Can't find permanent link"
    else
      url = url_part.attributes['href']
      puts url
      url_file.puts(url)
    end
  end

  nextpage = doc.at("//div[@class='pager-bottom pager-entries pager content-nav']/div.pager-inner/span.pager-right/a")
  
  if !nextpage.nil?
    starturl=nextpage.attributes['href'].strip
    puts starturl
  else
    break
  end
end


