require 'hpricot'
require 'open-uri'

@archiveArray=Array.new
def composeArcArray
  archivepage="http://boozynyc.com/archives.html"
  doc=Hpricot(open(archivepage))
  doc.search("//div[@class='archive-content']/ul/li/a").each do|each_m|
    if  !each_m.attributes['href'].nil?
      @archiveArray<<each_m.attributes['href']
    end
  end
end

def getUrls
  urls = File.open("urls","a+")
  @archiveArray.each do |each_m|
    puts each_m
    doc=Hpricot(open(each_m))
    doc.search("//div[@id='alpha-inner']/div[@class='entry-asset asset hentry']") do |entry|
      in_doc = Hpricot(entry.inner_html)
      head=in_doc.at("//h2[@class='asset-name entry-title']/a")
      if !head.nil?
        urls.puts(head.attributes['href'].strip)
        puts head.attributes['href'].strip
      end
    end
  end
end

composeArcArray
getUrls
