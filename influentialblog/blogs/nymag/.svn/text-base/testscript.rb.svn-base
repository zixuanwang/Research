require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'

def is_blog(url_or_path) 
 if url_or_path =~ /^http/ 
   (url_or_path =~ (/^http:\/\/[^\/]+\/daily/)) ? true : false
 else 
   (url_or_path =~ (/^\/daily/)) ? true : false
 end
end

def get_article_id_by_url(url) 
  if url =~ (/^http/)
    url.sub!(/^http:\/\/[^\/]+/, "")
  end
  if (is_blog(url)) 
   url.sub!(/^\//, "")
   url.gsub!(/\//, "-")
  else
    url.sub!(/\/[^\/]*$/, "")
    url.sub!(/^\//, "")
    url.gsub!(/\//, "-")
  end
end

  newfile = open("http://nymag.com/daily/food/2007/10/win_two_tickets_to_taste_of_ne.html").read

  doc = Hpricot(newfile)

script=doc.at("/html/body").inner_html.to_s;
  if script =~ /article_url: "(.*)"/
    blog_url = $1
    b_url = $1
  end

  article_id=get_article_id_by_url(b_url)
  prefix="http://nymag.com/comments/stories/"
  surfix="/comments/viewpost?page="
  script_url = prefix+article_id+surfix

  i = 1
  comments = []
  while(1)
    s_url=script_url+i.to_s
    puts s_url
    
    comm_page = Hpricot(open(s_url))
    flag = 0
    comm_page.search("//ul[@id='comment-list']/li").each do |comms|
      comm_entry = { }
      comm_entry[:content]=comms.at("/div").inner_text.gsub("\"", "\\\"").strip
      puts comms
      puts "=========================="
     # tmpauth=comms.at("/div[@class='info']/p[2]/i/a/cite");
     # puts tmpauth
     # puts "*******************************"
      tmpauth=comms.at("/div[@class='info']/p[2]/i/a/cite").inner_text.strip
      if tmpauth.empty?
        tmpauth = "anonymous"
      end
      comm_entry[:user]=tmpauth
      tmpdate=comms.at("/div[@class='info']/p[2]/i").next.inner_text.gsub(/\s/,"").strip + comms.at("/div[@class='info']/p[2]/i").next.next.inner_text.strip
      comm_entry[:date]=tmpdate
      comments << comm_entry
      flag = 1
    end
    if(flag==1)
      i+=1
    else
      break
    end
  end 
        
  comments.each do |each_comment|
    puts each_comment[:user].strip
    puts each_comment[:date].strip
    puts each_comment[:content].strip

  end
  print "======================================\n"

  
