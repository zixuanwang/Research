require 'hpricot'
require 'open-uri'

start = "http://www.yelp.com/c/nyc/restaurants"
prefix = "http://www.yelp.com"

def extractname(cat_url, cat_name)
#  puts cat_url
#  aFile = File.new("#{i}", "w")
#  econtent = Hpricot(open(cat_url)).to_s
#  if aFile
#    aFile.syswrite(econtent)
#  else
#    puts "Unable to open file!"
#  end
 
  e_doc = Hpricot(open(cat_url))
  e_doc.search("//div[@id='top_biz_lists']//a[@id*='top_biz_name_']").each do |ul|
    tmp = ul.attributes["title"]
    if !tmp.nil? and !tmp.empty?
      puts tmp
      name = cat_name+"##"+tmp
      @listFile.puts(name)
    end
  end
end

doc = Hpricot(open(start))
i = 1

@listFile = File.open("restaurantList", "w")
doc.search("//div[@id='sub_cat_lists']/ul/li/a").each do|li|
  tmp = li.attributes["href"]
  puts li.inner_text.strip
  url = prefix + tmp
#  puts url
  extractname(url, li.inner_text.strip)
  i = i + 1
end
@listFile.close
#extractname("#{ARGV[0]}")
