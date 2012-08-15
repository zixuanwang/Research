require 'hpricot'
require 'open-uri'

screen = ("1".."83")
@prefix="http://thestrongbuzz.com/buzz/"
pref = "http://thestrongbuzz.com/buzz/index.php?screen="
urls = File.open("urls","a+")
screen.each do |no|
  starturl = pref+no
  puts starturl
  doc=Hpricot(open(starturl))
  doc.search("span.post-title a").each do|each_p|
    purl=each_p.attributes["href"]
    url = @prefix+purl
    urls.puts(url)
  end
end

