require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'


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



def downloadbyMonth(year_number, month_number)
  month_array = [0,31,28,31,30,31,30,31,31,30,31,30,31]
  prefix = "http://newyork.seriouseats.com/"
  url_array = []
  i=1

  if year_number == 2008
    month_array[2] += 1
  end

  if(month_number<10)
    month = "0" + month_number.to_s
  else
    month = month_number.to_s
  end
  
  dir_name=year_number.to_s+"-"+month
  puts dir_name
  
  while (i <= month_array[month_number])
    if i<10
      num = "0" + i.to_s 
    else
      num = i.to_s
    end
    url = prefix + year_number.to_s + "/" + month + "/" + num +"/"
    url_array << url
    i += 1
  end
  
  url_array.each do |each_url|
    begin
    in_page = Hpricot(open(each_url))
    rescue => e 
      puts e
      if e.to_s.strip == "404 Not Found"
        next
      end
    end
    
    in_page.search("//div[@id='threeColumn1']/div[@class='post']").each do |each_post|
      page_url = each_post.at("/h3/a").attributes['href']
      puts page_url
      download_command="wget "+page_url+" -P "+ dir_name 
      system(download_command)
    end
    in_page.search("//div[@id='threeColumn1']/div[@class='post quickBites']").each do |each_post|
      page_url = each_post.at("/h3/a").attributes['href']
      puts page_url
      download_command="wget "+page_url+" -P "+ dir_name 
      system(download_command)
    end
  end  

end

month = [1,2,3,4,5,6,7,8,9,10,11,12]
yearArray = [2006,2007,2008]
yearArray.each do |each_year|
  month.each do |each_month|
    downloadbyMonth(each_year, each_month)
  end
end
