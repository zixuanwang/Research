require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'
require 'iconv'
class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",                                                  
                                  :host => "pierce.rutgers.edu",
                                  :username => "root",                                                  
                                  :password => "",
                                  :database => "Weblog")



urls = File.open(ARGV[0])
log = File.open("timelog","w")
urls.each_line do |u|
  puts u
  doc = Hpricot(open(u.strip)) 
  
  startnode = doc.at("//span.entry_page_posttitle").next
  text=""
  while 1
    if startnode.name == "hr"
      break
    else
      if startnode.text? and !startnode.to_s.empty?
        text += startnode.to_s
        log.puts text
      end
      startnode = startnode.next
    end
  end
    puts  text.strip
    if text.strip =~ /([^,]+),(.*)\s?by(.*)/
        date_t = $2 
        author = $3
        date = Time.parse(date_t.gsub(","," ")).strftime("%Y-%m-%d %H:%M:%S")
        url=u.strip
        
        sql =<<-SQL
          update blogs set publish_date = "#{date}" where url = "#{url}" 
        SQL
        DBConnection::connection.execute(sql)
     
        a = author.strip
        puts a
        sql =<<-SQL
          update blogs set author = "#{author}" where url = "#{url}" 
        SQL
        DBConnection::connection.execute(sql)
    end
    
end

