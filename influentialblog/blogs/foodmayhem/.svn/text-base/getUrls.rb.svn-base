require 'hpricot'
require 'open-uri'

range = ("1".."129")
prefix = "http://www.foodmayhem.com/page/"
url_file = File.open("urls","a+")
range.each do |each_r|
test_url = prefix+each_r
puts  test_url
doc = Hpricot(open(test_url))
doc.search("//div[@id='content']//div[@class='article-header']//h2[@class='article-title']").each do | each_post|
  innerdoc = Hpricot(each_post.inner_html)
  url = innerdoc.at("/a").attributes["href"]
  puts url
  url_file.puts(url)
end

end


