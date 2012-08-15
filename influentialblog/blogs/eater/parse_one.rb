require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
def parse
  doc = Hpricot(open(ARGV[0]))
  title = (doc/"/html/body/div/div[4]/div/span").inner_html.strip;
  puts title;
  author = doc.at("/html/body/div/div[4]/div/br").next.next.next.next;
  if author.to_s.strip =~ /(.*), by (.*)/
    blog_date=timetrans($1.strip)
    blog_author=$2
  end
  puts blog_date, blog_author 
  
  blog =(doc/"/html/body/div/div[4]/div/p")
  doc_entry = Hpricot(blog.inner_html.strip);
  links = doc_entry.search("[@href]").each do |link_entry| 
    puts link_entry.attributes["href"];
  end
  puts blog.inner_text;

  script_url = ""
  doc.search("/html/body/div/div[4]/div/script").each do |script|
    if script.attributes['src'] =~ /comments\.js/
        script_url = script.attributes['src']
    end
  end

  comments = Hpricot(open(script_url)).to_s;
  comments = comments[comments.index("\\")  ... comments.rindex("\"")].gsub("\\u003C", "<").gsub("\\u003E", ">")
  comments.gsub!("\\\"","\"");
  comments.gsub!("\\n", "");
  comments.gsub!("\\t", "");

  comments_array = []
  comment_html = Hpricot(comments);
  comment_html.search("//div[@class='comment ']").each do |comment_entry|
    comments_array_entry = {}
    comments_array_entry[:content] = comment_entry.at("//div[@class='comment-body']/p").inner_text
    comments_array_entry[:user] = comment_entry.at("//div[@class='comment-who']/a").attributes["alt"];
    
    comments_array_entry[:date] = timetrans(comment_entry.search("//div[@class='comment-when']/a")[1].inner_text);
    comments_array << comments_array_entry;
  end

  comments_array.each do |tmp|
    puts tmp[:content], tmp[:user], tmp[:date]
  end
end

def timetrans(orig)
  if orig =~ /(\d+)\/(\d+)\/(\d+) (\d+):(\d+) ([AP]M)/ 
    tmpdate = "20"+$3+"-"+$1+"-"+$2;    
    t=$4;
    
    if $6 == "PM"
      if t.to_i < 12
        t = (t.to_i + 12).to_s
      end
    end
    tmptime= t +":"+$5+":"+"00"
    final=tmpdate+" "+tmptime
  else
    month_hash = {"January" => "01", "February"=> "02", "March" => "03", "April" => "04", "May" => "05", "June" => "06",
                  "July" => "07", "August" => "08", "September" => "09", "October" => "10", "November" => "11", "December"=> "12"}
    if orig =~ /(.*), (.*)\s+(\d+), (\d+)/
      final=$4+"-"+month_hash[$2.strip]+"-"+$3+" "+"00:00:00"
    end
  end
    
end

parse
