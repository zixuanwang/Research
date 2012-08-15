require 'hpricot'
require 'open-uri'

prefix="http://nyjournal.squarespace.com/journal/?currentPage="
pref = "http://nyjournal.squarespace.com"
numbers=("1".."87")
urls = File.open("urls","a+")
numbers.each do|n|
  starturl = prefix+n
  puts starturl
  doc = Hpricot(open(starturl))
  doc.search("//div[@class='journal-entry']").each do |pdiv|
    if pdiv.at("//h2[@class='title']/a").nil?
      puts "can't find it's link"
    else
      url = pref+pdiv.at("//h2[@class='title']/a").attributes['href'].strip
      
      puts url
      urls.puts(url)
    end
  end
  
end
