require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl="http://www.walkernewyork.com/eats/archives.html"
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
  end
  doc.search("//div[@class='archive-individual archive-date-based archive']/div[@class='archive-content']/ul.archive-list/li").each do | each_post|
    innerdoc = Hpricot(each_post.inner_html)
    url = innerdoc.at("/a").attributes["href"]
    puts url
    url_file.puts(url)
  end


