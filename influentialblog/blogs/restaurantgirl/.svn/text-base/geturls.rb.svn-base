require 'hpricot'
require 'open-uri'

prefix="http://restaurantgirl.com/?offset="
numbers=("1".."627")
urls = File.open("urls","a+")
numbers.each do|n|
  starturl = prefix+n
  puts starturl
  doc = Hpricot(open(starturl))
  doc.search("//div[@class='entry-asset asset']").each do |pdiv|
    if pdiv.at("//h2[@class='asset-name']/a").nil?
      puts "can't find it's link"
    else
      url = pdiv.at("//h2[@class='asset-name']/a").attributes['href'].strip
      puts url
      urls.puts(url)
    end
  end
  
end
