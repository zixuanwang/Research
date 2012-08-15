require 'hpricot'
require 'open-uri'

urls =File.open("urls","a+")
starturl="http://slice.seriouseats.com/archives/2009/05/17-week/"
while 1
  doc = Hpricot(open(starturl))
  doc.search("//div.post").each do|p|
    in_doc=Hpricot(p.inner_html)
    a = p.at("/h3/a")
    if a.nil?
      puts "can't find permanent link?"
    else
      url = a.attributes['href'].strip
      puts url
      urls.puts(url)
    end
  end
#  doc.search("//div[@class='post quickBites']").each do|p|
#    a=p.at("/h3/a")
#    if a.nil?
#      puts "can't find permanent link?"
#    else
#      url = a.attributes['href'].strip
#      puts url
#      urls.puts(url)
#    end
#  end

  nextpage = doc.at("//div#pageNav/h3.left/a")
  if nextpage.nil?
    break
  else
    starturl = nextpage.attributes['href'].strip
  end
  
end
