require 'hpricot'
require 'open-uri'

monthrange = ("01".."12")
yearange = ("2006".."2009")
prefix = "http://thewanderingeater.com/"
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
    doc.search("//td[@id='middle']//div[@class='post']").each do | each_post|
      innerdoc = Hpricot(each_post.inner_html)
      begin
      url = innerdoc.at("/div[@class='post-headline']/h2/a").attributes["href"]
      rescue Encoding::CompatibilityError => encoding
        puts "drop url because.. #{encoding}"
        next
      end
      puts url
      url_file.puts(url)
    end

  end
end


