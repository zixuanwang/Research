require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl = "http://www.winedanddined.com/"

while 1
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
    break
  end
  doc.search("//div[@class='post']").each do | each_post|
    innerdoc = Hpricot(each_post.inner_html)
    url = innerdoc.at("/h2[@class='title']/a").attributes["href"]
    puts url
    url_file.puts(url)
  end

  nexturl =""
  doc.search("//p[@align='center']/a").each do |center|
    if center.inner_text.strip =~ /Next.*/
      nexturl = center.attributes['href'].strip
    else 
      next
    end
  end
  
  if !nexturl.empty?
    starturl=nexturl
    puts starturl
  else
    break
  end
end


