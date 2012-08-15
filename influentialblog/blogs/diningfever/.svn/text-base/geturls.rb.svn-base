require 'hpricot'
require 'open-uri'

starturl = "http://www.diningfever.com/blog/"
doc=Hpricot(open(starturl))
arc_array=Array.new
doc.search("//div#r_sidebar/ul/li#Archives/ul/li/a").each do|li|
  if li.nil?
    puts "Can't get archive link"
  else
    arc = li.attributes['href'].strip
    arc_array<<arc
  end
end

urls=File.open("urls","a+")
arc_array.each do|mon|
  in_doc = Hpricot(open(mon))
  in_doc.search("//div#contentmiddle/div.contenttitle/h1/a").each do|l|
    if l.nil?
      puts "Can't find post's link"
    else
      url = l.attributes['href'].strip
      puts url
      urls.puts(url)
    end
  end
end
