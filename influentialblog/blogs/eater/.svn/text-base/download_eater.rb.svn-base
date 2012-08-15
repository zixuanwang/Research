require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'

def mkdirName(url)
  if url=~ /(.*)archives\/(\d+)\/(\d+)\//
    dirName =$2+"-"+$3
  end
end

def getListnumber(url)
  max_page = 1
  first_doc = Hpricot(open(url))
  first_doc.search("//div[@id='pages']/a").each do|each_page|
     if each_page.attributes['href'].strip =~ /(.*)page=(\d+)$/ 
      current_page = $2
      if current_page.to_i > max_page
          max_page = current_page.to_i
      end
    end
  end
  return max_page
end


def download1Month(month_url)
  dir_name = mkdirName(month_url)  
  puts dir_name
  last_pageNumber = getListnumber(month_url)
  print "this month has: ", last_pageNumber, " pages\n"
  middle_url = "index.php?page=" 
  i=1
  while(i <= last_pageNumber) 
    page_url = month_url + middle_url + i.to_s
    puts page_url
    in_page = Hpricot(open(page_url))
    in_page.search("//div[@id='column1']/h1[@class='posttitle']/a[@class='posttitle']").each do |each_post|
      download_command="wget " + each_post.attributes['href'] + " -P " + dir_name 
      puts download_command
      system(download_command)
    end
    i += 1
  end

end

def downloadbyMonth(year, month)
  if( month < 10 )
    month_s = "0"+month.to_s
  else
    month_s = month.to_s
  end
  dirName = year.to_s + "-" + month_s

  puts dirName
  eater_prefix = "http://eater.com/archives/"
  month_url = eater_prefix + year.to_s + "/" + month_s+"/"
  puts month_url
  
  last_pageNumber = getListnumber(month_url)
  print month, " month has: ", last_pageNumber, " pages\n"
  
  middle_url = "index.php?page=" 
  i=1
  while(i <= last_pageNumber) 
    page_url = month_url + middle_url + i.to_s
    puts page_url
    in_page = Hpricot(open(page_url))
    in_page.search("//div[@id='column1']/h1[@class='posttitle']/a[@class='posttitle']").each do |each_post|
      download_command="wget " + each_post.attributes['href'] + " -P " + dirName 
      puts download_command
      system(download_command)
    end
    i += 1
  end

end

yearArray = [2006, 2007,2008]
monthArray = [1,2,3,4,5,6,7,8,9,10,11,12]
#monthArray = ["http://eater.com/archives/2009/01/","http://eater.com/archives/2009/02/","http://eater.com/archives/2009/03/"]
yearArray.each do |each_year|
  monthArray.each do|each_month|
    downloadbyMonth(each_year, each_month)
  end
end
