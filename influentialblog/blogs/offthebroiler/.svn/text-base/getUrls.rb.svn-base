require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl = "http://offthebroiler.wordpress.com/"

while 1
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
    break
  end
  doc.search("//div[@id='content']/div").each do | each_post|
    innerdoc = Hpricot(each_post.inner_html)
    perm = innerdoc.at("/h2/a")
    if perm.nil?
      next
    else
      begin
      url = perm.attributes['href']
      puts url
      url_file.puts(url)
      rescue Encoding::CompatibilityError=> encoding
        puts encoding 
        next
      end
  
    
    end
    
    end

  nexturl =""
  nextpart = doc.at("//div.navigation/div.alignleft/a")
  if nextpart.nil?
    break
  else 
    nexturl = nextpart.attributes['href'].strip
    starturl = nexturl
    puts starturl
  end
end


