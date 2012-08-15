require 'hpricot'
require 'open-uri'

url_file = File.open("urls","a+")
starturl = "http://www.nycfoodie.com/nycfoodie/"
pref = "http://www.nycfoodie.com/nycfoodie/"
while 1
  begin
  doc = Hpricot(open(starturl))
  rescue =>e
    puts e
    break
  end

  doc.search("a[text()*='permalink']").each do |each_post|
    perm = each_post.attributes['href'].strip
    puts perm
    url_file.puts(perm)
  end
  
   
 # doc.search("//div[@id='content']/div").each do | each_post|
 #   innerdoc = Hpricot(each_post.inner_html)
 #   perm = innerdoc.at("/h2/a")
 #   if perm.nil?
 #     next
 #   else
 #     begin
 #     url = perm.attributes['href']
 #     puts url
 #     url_file.puts(url)
 #     rescue Encoding::CompatibilityError=> encoding
 #       puts encoding 
 #       next
 #     end
 # 
 #   
 #   end
 #   
 #   end

  nexturl =""
  nextpart = doc.at("//span[@style='float: right;']/a")
  if nextpart.nil?
    break
  else 
    nexturl = nextpart.attributes['href'].strip
    starturl = pref +nexturl
    puts starturl
  end
end


