require 'hpricot'
require 'open-uri'

prefix="http://www.nycnosh.com/index.php?paged="
numbers=("1".."43")
urls = File.open("urls","a+")
numbers.each do|n|
  starturl = prefix+n
  puts starturl
  doc = Hpricot(open(starturl))
  doc.search("//div.post").each do |pdiv|
    if pdiv.at("/h3.storytitle/a").nil?
      puts "can't find it's link"
    else
      url = pdiv.at("/h3.storytitle/a").attributes['href'].strip
      puts url
      urls.puts(url)
    end
  end
  
end
