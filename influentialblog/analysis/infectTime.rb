require "rubygems"
require "activerecord"
require "time"

class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",                                                           :host => "ursa.rutgers.edu",
                                  :username => "root",                                                           :password => "",
                                  :database => "Weblog")

def recordTimeInterval
file =File.open("blog_ralation","r+")
#logfile = File.open("infecttime.log","w+")
errfile = File.open("infect.err","w+")
timefile = File.open("infect.time", "w+")

while line = file.gets
  from = line.split(" ")[0]
  to = line.split(" ")[1]
  sql =<<-SQL
    select site_id, blog_id, publish_date from blogs where blog_url = "#{from}"
  SQL

  times = DBConnection::connection.select_all(sql)[0]
  if times.nil?
    errfile.puts("NO SELECT RESULT--FROM!\n#{from}")    
  else
    from_time = times["publish_date"]
    from_id = times["blog_id"]
    to_site_id = times["site_id"]
  end

  sql =<<-SQL
    select site_id,blog_id, publish_date from blogs where blog_url = "#{to}"
  SQL

  times = DBConnection::connection.select_all(sql)[0]
  if times.nil?
    errfile.puts("NO SELECT RESULT--TO!\n#{to}")
  else
    to_time = times["publish_date"]
    to_id = times["blog_id"]
    from_site_id = times["site_id"]
  end
  
  if !from_id.to_s.empty? and !to_id.to_s.empty? and from_time != "0000-00-00 00:00:00" and to_time != "0000-00-00 00:00:00"
    t1 = Time.parse("#{to_time}")
    t2 = Time.parse("#{from_time}")
    timefile.puts("#{to_site_id}, #{to_id},#{from_site_id}, #{from_id},#{t2-t1}")
    #logfile.puts("#{from_id}\t#{from_time}\t#{to_id}\t#{to_time}")
  end
end

end #end of recordTimeInterval

def computeAvgInfectTime
  inputfile = File.open("infect.time","r+")
  backlinkfile = File.open("backinfect.time","w+")
  infectSites_array = Array.new(7)
  while line=inputfile.gets
    eachpart = line.split(",")
    to_site_id = eachpart[0].to_i
    from_site_id = eachpart[2].to_i
    infectime = eachpart[4].to_f
    if infectime > 0
      puts("#{to_site_id}\t#{from_site_id}\t#{infectime}")
      if infectSites_array[to_site_id-1].nil?
        infectSites_array[to_site_id-1]=Hash.new
        infectSites_array[to_site_id-1][from_site_id]=Array.new
        infectSites_array[to_site_id-1][from_site_id]<<infectime
      else
        if infectSites_array[to_site_id-1][from_site_id].nil?
          infectSites_array[to_site_id-1][from_site_id]=Array.new
          infectSites_array[to_site_id-1][from_site_id]<<infectime
        else
          infectSites_array[to_site_id-1][from_site_id]<<infectime
        end
      end
    else
      backlinkfile.puts(line)
    end
  end #end of while

  outfile = File.open("infect.time.report","w+")
  i=1
  infectSites_array.each do |each_site|
    each_site.each do |key,value|
      sum = 0.0
      count = 0
      average = 0.0
      value.each do |each_v|
        count += 1
        sum += each_v
      end
      average = sum/count
      if average > 3600*24 
        outfile.write(sprintf("%d\t%d\t%.2f days\n", i, key, average/3600/24))
      else if average > 3600
        outfile.write(sprintf("%d\t%d\t%.2f hours\n", i, key, average/3600))
      else
        outfile.write(sprintf("%d\t%d\t%.2f seconds\n", i, key, average))
      end
    end
    end
    i += 1
  end

end # end of computeAveInfectTime
#recordTimeInterval
computeAvgInfectTime
