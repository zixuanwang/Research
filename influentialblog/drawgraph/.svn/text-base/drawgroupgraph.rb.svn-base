require "rubygems"
require "graphviz"
require "activerecord"

class DBConnection < ActiveRecord::Base
end

DBConnection.establish_connection(:adapter => "mysql",                         
                                  :host => "pierce.rutgers.edu",
                                  :username => "root",                         
                                  :password => "",
                                  :database => "Weblog_development")

name = ARGV[0]
      
if name.nil? or name.empty?
  puts "input the restaurant name!"
  exit(1)
end

      sql =<<-SQL
      select site_id,sites.name, blogs.id as blog_id, unix_timestamp(date(publish_date)) as pdate from sites,blogs where title like "%#{name}%" and sites.id = blogs.site_id order by pdate;
      SQL
      sites = DBConnection::connection.select_all(sql)
      nodes = Array.new
      rank = Array.new
      sites.each do |row|
        rank << row["pdate"].to_i
        tmp=Hash.new
        tmp["blog_id"] = row["blog_id"]
        tmp["date"] = row["pdate"].to_i
        tmp["site_id"] = row["site_id"]
        tmp["site_name"] = row["name"]
        nodes << tmp
      end

  
    sql =<<-SQL
    select S.site_id as s_site, S.name as s_name, S.id as s_id, unix_timestamp(date(S.publish_date)) as s_date, P.id as l_id, P.site_id as l_site, sites.name as l_name, unix_timestamp(date(P.publish_date)) as l_date from (select T.site_id, T.name, T.id, T.publish_date, blogs_outlinks.outlink_id from (select site_id, sites.name, blogs.id, publish_date, content from blogs,sites where title like "%#{name}%" and blogs.site_id = sites.id)T left join blogs_outlinks on T.id = blogs_outlinks.blog_id  order by T.publish_date)S, outlinks, blogs P, sites where S.outlink_id = outlinks.id and outlinks.url = P.url and P.site_id = sites.id;
    SQL

      refsites = DBConnection::connection.select_all(sql)
    
      refsites.each do |row|
        tmp=Hash.new
        tmp["blog_id"] = row["s_id"]
        tmp["date"] = row["s_date"].to_i
        tmp["site_id"] = row["s_site"]
        tmp["site_name"] = row["s_name"]
        if !nodes.include?(tmp)
          nodes << tmp
        end
        
        tlmp=Hash.new
        tlmp["blog_id"] = row["l_id"]
        tlmp["date"] = row["l_date"].to_i
        tlmp["site_id"] = row["l_site"]
        tlmp["site_name"] = row["l_name"]
        if !nodes.include?(tlmp)
          nodes << tlmp
        end

        rank << row["s_date"].to_i
        rank << row["l_date"].to_i
      end
      #puts rank.sort
    
      gFile = File.open("group.dot", "w")
      gFile.puts("digraph group{")
      gFile.puts("\tranksep=.75;size=\"7.5,7.5\";")
      gFile.puts("\t{\nnode[shape=plaintext,fontsize=16];")
     
      timestr=""
      timeline = Array.new
      rank.sort!.uniq!.each do |l|
        t = Time.at(l).strftime("%Y-%m-%d")
        timeline << t
      end
     
      count = 0
      str = "\""+timeline[count]+"\""+"->"
      count += 1
      while count < timeline.length()-1
        str += "\""+timeline[count]+"\""+"->"
        count += 1  
      end
      str += "\""+timeline[count]+"\""

      gFile.puts("\t#{str};\n}")
      rank.each do |l|
        t = Time.at(l).strftime("%Y-%m-%d")
        rankstr = "{rank = same; \"#{t}\";"
        nodes.each do |row|
          if row["date"].to_i == l
            rankstr +="\"#{row["site_id"]}:#{row["site_name"]}:#{row["blog_id"]}\";"
          end
        end
          rankstr += "}"
          gFile.puts(rankstr)
      end
      
     revsites = sites.reverse
      sites.each do|l|
        revsites.each do |s|
          if s["pdate"] > l["pdate"] 
            gFile.puts("\"#{s["site_id"]}:#{s["name"]}:#{s["blog_id"]}\"->\"#{l["site_id"]}:#{l["name"]}:#{l["blog_id"]}\";")
          end
        end
      end
      
      gFile.puts("edge[color=red];")
      refsites.each do|row|
          gFile.puts("\"#{row["s_site"]}:#{row["s_name"]}:#{row["s_id"]}\"->\"#{row["l_site"]}:#{row["l_name"]}:#{row["l_id"]}\";")
      end

      gFile.puts("}")
      gFile.close()
