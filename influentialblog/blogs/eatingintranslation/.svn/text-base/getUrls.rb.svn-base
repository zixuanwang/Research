require 'hpricot'
require 'open-uri'

monthrange = ("01".."12")
yearange = ("2005".."2009")
prefix = "http://www.eatingintranslation.com/"
url_file = File.open("urls","a+")
yearange.each do |each_y|
  monthrange.each do |each_m|
    test_url = prefix+each_y+"/"+each_m+"/"
    puts  test_url
    begin
    doc = Hpricot(open(test_url))
    rescue =>e
      puts e
      next
    end
    doc.search("//div[@id='alpha-inner']//div[@class='entry']").each do | each_post|
      innerdoc = Hpricot(each_post.inner_html)
      url = innerdoc.at("/h3[@class='entry-header']/a").attributes["href"]
      puts url
      url_file.puts(url)
    end

  end
end


