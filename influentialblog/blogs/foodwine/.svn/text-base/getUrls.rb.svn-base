require 'hpricot'
require 'open-uri'

monthrange = ("1".."12")
yearange = ("2007".."2009")
prefix = "http://www.foodandwine.com/blogs/mouthing-off/"
test_url = "http://www.foodandwine.com/blogs/mouthing-off/2007/2"
url_file = File.open("urls","a+")
yearange.each do |each_y|
  monthrange.each do |each_m|
    test_url = prefix+each_y+"/"+each_m
    puts  test_url
    begin
    doc = Hpricot(open(test_url))
    rescue =>e
      puts e
      next
    end
    doc.search("//div[@id='content']//div[@class='entry']").each do | each_post|
      innerdoc = Hpricot(each_post.inner_html)
      url = innerdoc.at("/h1/a").attributes["href"]
      puts url
      url_file.puts(url)
    end

  end
end


