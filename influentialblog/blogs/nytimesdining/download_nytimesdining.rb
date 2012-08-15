require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'


twitter_prefix = "http://twitter.com/nytimesdining?page="
i=1
while i<125
  FileUtils.mkdir_p i.to_s

  url_list = twitter_prefix+i.to_s
  puts url_list
  begin
   in_page = Hpricot(open(url_list))
   rescue => e 
     puts e
     if e.to_s.strip == "404 Not Found"
       print  url_list, " not found." 
     end
   end
  
  in_page.search("//ol[@id='timeline']/li").each do |each_post|
      page_url = each_post.at("/span[@class='status-body']/span[@class='entry-content']/a")
      if !page_url.nil?
        puts page_url.inner_text
        download_command="wget "+page_url.inner_text+" -P "+ i.to_s 
        system(download_command)
      else
        next
      end
    end
  puts "###############################"
  i+=1
end
