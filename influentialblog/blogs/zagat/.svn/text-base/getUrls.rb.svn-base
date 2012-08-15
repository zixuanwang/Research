require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl = "http://www.zagat.com/Blog/EntryList.aspx?SNP=NNYC&SCID=40"
prefix = "http://www.zagat.com"
while 1
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
    break
  end
  doc.search("//div[@class='blogHdr']").each do | each_post|
    innerdoc = Hpricot(each_post.inner_html)
    url = innerdoc.at("/h3/a").attributes["href"]
    puts url
    url_file.puts(url)
  end

  nexturl =""
  nextpart = doc.at("//div.blogPaging/a.next")
  if nextpart.nil?
    break
  else
    nexturl=prefix+nextpart.attributes['href'].strip
  end
  
  if !nexturl.empty?
    starturl=nexturl
    puts starturl
  else
    break
  end
end


