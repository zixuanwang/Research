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
        nodes << tmp
      end

  
    sql =<<-SQL
    select S.site_id as s_site, S.name as s_name, S.id as s_id, unix_timestamp(date(S.publish_date)) as s_date, P.id as l_id, P.site_id as l_site, sites.name as l_name, unix_timestamp(date(P.publish_date)) as l_date from (select T.site_id, T.name, T.id, T.publish_date, blogs_outlinks.outlink_id from (select site_id, sites.name, blogs.id, publish_date, content from blogs,sites where title like "%#{name}%" and blogs.site_id = sites.id)T left join blogs_outlinks on T.id = blogs_outlinks.blog_id  order by T.publish_date)S, outlinks, blogs P, sites where S.outlink_id = outlinks.id and outlinks.url = P.url and P.site_id = sites.id;
    SQL

      refsites = DBConnection::connection.select_all(sql)
    
      refsites.each do |row|
        rank << row["s_date"].to_i
        rank << row["l_date"].to_i
      end
      #puts rank.sort
    
      graph = GraphViz::new("G", "output" => "png", "nodesep" => ".1")
     
      timestr=""
#      rank.sort!.each do |l|
#        t = Time.at(l).strftime("%Y-%m-%d")
#        graph.add_node("#{l}","shape"=>"plaintext", "label"=>"#{t}")
#      end
#     
#      count = rank.length() -1
#      while count > 0
#        graph.add_edge("#{rank[count]}","#{rank[count-1]}")
#        count -= 1
#      end
     
     sites.each do |row|
        graph.add_node("#{row["blog_id"]}", "rank" => "same;#{(row["pdate"].to_i)}; #{row["blog_id"]}", :label => "#{row["site_id"]}:#{row["name"]}:#{row["blog_id"]}", "fontcolor"=>"blue")
     end
     
    refsites.each do |row|
      tsmp=Hash.new
      tsmp["blog_id"] = row["s_id"]
      tsmp["date"] = row["s_date"]
      if !nodes.include?(tsmp)
        graph.add_node("#{row["s_id"]}", "rank"=>"same;#{row["s_date"].to_i}",:label => "#{row["s_site"]}:#{row["s_name"]}:#{row["s_id"]}")
      end
      tlmp = Hash.new
      tlmp["blog_id"] = row["l_id"]
      tlmp["date"] = row["l_date"]
      if !nodes.include?(tlmp)
        graph.add_node("#{row["l_id"]}", "rank"=>"same; #{row["l_date"].to_i}",:label => "#{row["l_site"]}:#{row["l_name"]}:#{row["l_id"]}")
      end
    end
     
     revnodes = nodes.reverse
      nodes.each do|l|
        revnodes.each do |s|
          if s["date"] > l["date"] 
            graph.add_edge("#{s["blog_id"]}", "#{l["blog_id"]}")
          end
        end
      end
       
      refsites.each do|row|
           graph.add_edge("#{row["s_id"]}", "#{row["l_id"]}", "color"=>"red")
      end

graph.output(:file => "implicit.jpeg" )




