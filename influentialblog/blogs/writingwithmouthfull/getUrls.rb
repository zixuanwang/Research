require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl = "http://www.writingwithmymouthfull.com/"
prefix = "http://www.zagat.com"
while 1
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
    break
  end
  doc.search("//div[@class='post']").each do | each_post|
    innerdoc = Hpricot(each_post.inner_html)
    url = innerdoc.at("/h1/a").attributes["href"]
    puts url
    url_file.puts(url)
  end

  nexturl =""
  doc.search("//div.alignleft/h3.prevnext/a").each do |center|
    if center.inner_text.strip =~ /.*Older Entries.*/
      nexturl = center.attributes['href'].strip
      break
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


