require 'hpricot'
require 'open-uri'

monthrange = ("01".."12")
yearange = ("2007".."2009")
prefix = "http://nycfoodguy.com/"
url_file = File.open("urls","a+")
yearange.each do |each_y|
  monthrange.each do |each_m|
    test_url = prefix+each_y+"/"+each_m
    while 1
      puts  test_url
      begin
      doc = Hpricot(open(test_url))
      rescue =>e
        puts e
        break
      end
      doc.search("//div[@id='content']/h1/a").each do | each_post|
        if !each_post.attributes["href"].nil?
          url = each_post.attributes["href"]
          puts url
          url_file.puts(url)
        end
      end
      previous=doc.at("//div[@class='navigation']/div[@class='alignleft']/a")
      if previous.nil?
        break
      else
        test_url=previous.attributes['href']
      end
    end#end of while 1
  end #end of month
end #end of year


