require 'hpricot'
require 'open-uri'

@url_file = File.open("urls","a+")
def main 
  monthrange = ("01".."12")
  yearange = ("2007".."2009")
  prefix = "http://www3.timeoutny.com/newyork/the-feed-blog/restaurants-bars/"
  yearange.each do |each_y|
    monthrange.each do |each_m|
      test_url = prefix+each_y+"/"+each_m
      puts  test_url
      getURLs(test_url)
    end
  end
end

def getURLs(url_name)
  begin
    doc = Hpricot(open(url_name))
    rescue =>e
      puts e
    return
    end
   doc.search("//div[@class='post LY_clear']").each do | each_post|
      innerdoc = Hpricot(each_post.inner_html)
      begin
      url = innerdoc.at("/h2/a").attributes["href"]
      rescue Encoding::CompatibilityError => encoding 
        puts encoding
        next
      end
      puts url
      @url_file.puts(url)
    end
end

main
