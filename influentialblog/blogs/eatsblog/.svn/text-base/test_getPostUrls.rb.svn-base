require 'hpricot'
require 'open-uri'

def test(test_url)
urlist = File.open("eatsblog.urls", "a+")
begin
  doc = Hpricot(open(test_url))
rescue => e
  puts e
  return
end

doc.search("//table[@id='blog-body-heading']").each do |each_p|
  inside_doc = Hpricot(each_p.inner_html)
  if !inside_doc.at("//div[@class='entry']//a").nil?
    url = inside_doc.at("//div[@class='entry']//a").attributes['href']
    urlist.puts(url)
  end
end
end

#urlist = File.open("eatsblog.urls", "a+")
prefix = "http://eatsblog.guidelive.com/archives/"
year = [2007,2008,2009]
month = ("01".."12")

test_url = "http://eatsblog.guidelive.com/archives/2007/05/"
test(test_url)

