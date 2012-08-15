require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'

Hpricot.buffer_size = 262144

def normalize_text(text)
 unicode_ansc = {
  '&#8211;' => '-',
  '&#8212;' => '--',
  '&#8220;' => '"',
  '&#8221;' => '"',
  '&#8216;' => '\'',
  '&#8217;' => '\'',
  '&#8230;' => '...',
  '&#183;'  => '.',
  '&#151;'  => '--',
  '&#150;'  => '-',
  '&#228;' => 'ä' ,
  '&#246;' => 'ö',
  '&#220;' => 'Ü',
  '&#252;' => 'ü',
  '<91>' => '\'',
  '<92>' => '\'',
 }

 unicode_ansc.each do |key, value|
   text.gsub!(key, value)
 end
end

def timetrans(orig)
  orig.gsub!(" ","")
  month_hash = {"January" => "01", "February"=> "02", "March" => "03", "April" => "04", "May" => "05", "June" => "06",
                  "July" => "07", "August" => "08", "September" => "09", "October" => "10", "November" => "11", "December"=> "12"}
  if orig =~ /([^\d]+)(\d+),(\d+)/ 
      final=$3+"-"+month_hash[$1]+"-"+$2+" "+"00:00:00"
  end
  return final
end

def parse(file_name)
  
  
  #get content
  doc = Hpricot(open(file_name))
  file_text = open(file_name).read
  doc = Hpricot(file_text)
  wholepage = file_text.to_s 

  #get title
  if wholepage =~ /function getShareHeadline([^\{]*)\{([^\}]*)\}/
    inside =$2
    inside = inside.strip
    if inside =~ /return encodeURIComponent\('([^']*)'\)/
      t = $1
    end
  end
  puts t
  normalize_text(t)
  puts t
return
  #get title
  t = doc.search("//div[@id='article']/h1/nyt_headline")
  if t.nil?
    puts "can't find title!!!"
  else
    title=t.inner_text.strip
  end
 print "title before: ", title, "\n"
  normalize_text(title)
  print "Title: ", title, "\n"
  
 
  
  
  #get author
  a = doc.at("//nyt_byline/div[@class='byline']/a")
  if a.nil?
    aa = doc.at("//div[@class='byline']")
    if aa.nil?
    puts "can't find author!!!"
    else
      author = aa.inner_text.strip
      if author =~ /^By (.*)/
        author = $1
      end
    end
  else
    author = a.inner_text.strip
  end
  
  if author.nil?
    author = "anonymous"
  end
puts author
return

  doc.search("script").remove
  doc.search("style").remove
  content = ""
  body = doc.search("//div[@id='articleBody']//p")
  if body.nil?
    puts "empty body!!"
  else
    body.each do |p|
      if !p.inner_text.strip.nil? and !p.inner_text.strip.empty?
        content += p.inner_text.strip
        content += " "
      end
  end
  end
  
  content.gsub!(/\s+/," ")
  puts content


return
  links = Array.new
  doc.search("//div[@id='articleBody']/nyt_text//a").each do |link_entry|
    if !link_entry.attributes["href"].nil?
      links << link_entry.attributes["href"].strip
    end
  end

  content = ""
  c = doc.search("//div[@id='articleBody']/nyt_text")

  if c.nil?
    puts "can't find Content!!!"
  else
    para = Hpricot(c.inner_html)
    para.search("//p").each do |each_p|
      if !each_p.nil?
        content += each_p.inner_text.strip
      end
    end
  end
  
  next_page = doc.search("//div[@id='articleBody']/nyt_text/div[@id='pageLinks']/ul[@id='pageNumbers']")
  if !next_page.nil?
    begin
      page_number = Hpricot(next_page.inner_html)
    rescue Exception => e
      puts e
    end
    prefix = "http://www.nytimes.com/"
    page_number.search("//li/a").each do |next_number|
      next_url = next_number.attributes["href"].strip
      next_url = prefix+next_url
      print "next page: ", next_url, "\n"
      downloadcmd = "wget \""+next_url+"\" -O "+"temp"
      system(downloadcmd)
      system("doc2unix temp")
      next_doc = Hpricot("temp")
      puts "parse temp!!!"
     
      next_doc.search("//div[@id='articleBody']/nyt_text//a").each do |link_entry|
        if !link_entry.attributes["href"].nil?
          links << link_entry.attributes["href"].strip
        end
      end
      
      next_para = next_doc.search("//div[@id='articleBody']/nyt_text//p")
      if next_para.empty?
        puts "inner_text!!!"
        puts next_doc.search("//div[@id='articleBody']/nyt_text/").inner_text.strip
        puts "##########################"
      else
        puts "temp has p!!!"
        puts next_para    
        puts "**********************"
        next_para.each do |each_p|
            if !each_p.nil?
              puts "temp's para!!!"
              p_content = each_p.inner_text.strip
              puts "has p_content!!!"
              content += p_content
            end
          end
      end
    end
  end
 

  if !content.nil?
    normalize_text(content)
    content = content.gsub('"','\"')
    puts "========================"
  end

  log.puts("URL:")
  log.puts(url)
  log.puts("Title:")
  log.puts(title)
  log.puts("Author:")
  log.puts(author)
  log.puts("Date:")
  log.puts(blog_date)
  log.puts("Content:")
  log.puts(content)
  log.puts("Links:")
  links.uniq!
  links.each do |l|
    if l =~ /^http:\/\/(.*)/
      log.puts(l)
    else
      links.delete(l)
    end
  end
  log.puts("\n")
  log.close 
  return
  puts "===================================================="

end

parse("temp")
