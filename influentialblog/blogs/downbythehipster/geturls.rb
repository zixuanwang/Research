require 'hpricot'
require 'open-uri'

prefix="http://www.downbythehipster.com/blog/?currentPage="
numbers=("1".."129")
pref = "http://www.downbythehipster.com"
urls = File.open("urls","a+")
numbers.each do|n|
  starturl = prefix+n
  puts starturl
  doc = Hpricot(open(starturl))
  doc.search("//div[@class='journal-entry']").each do |pdiv|
    if pdiv.at("//h2[@class='title']/a").nil?
      puts "can't find it's link"
    else
      half = pdiv.at("//h2[@class='title']/a").attributes['href'].strip
      url = pref+half
      puts url
      urls.puts(url)
    end
  end
  
end
