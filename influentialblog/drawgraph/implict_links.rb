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
      select rest_id, rest_name, blog_id, blogs.site_id,site_name, date(publish_date) as dd from rests_blogs,blogs where blogs.id = blog_id and rest_name like "%#{name}%"  order by rest_id, publish_date;
      SQL
      sites = DBConnection::connection.select_all(sql)
      nodes = Array.new
      timestr = ""
      sites.each do |row|
        timestr += row["dd"]
        timestr += " "
        tmp=Hash.new
        tmp["blog_id"] = row["blog_id"]
        tmp["date"] = row["dd"]
        puts row["dd"]
        nodes << tmp
      end

      timestr.strip.gsub!(" ",";")
      puts timestr      
      graph = GraphViz::new("G", "output" => "png", "nodesep" => ".1", "rank" => "#{timestr}")
      
     sites.each do |row|
        graph.add_node("#{row["blog_id"]}", "rank" => "same;#{row["dd"]}", :label => "#{row["site_id"]}:#{row["site_name"]}:#{row["blog_id"]}")
     end
      
      revnodes = nodes.reverse
      nodes.each do|l|
        revnodes.each do |s|
          if s["date"] > l["date"]
            graph.add_edge("#{s["blog_id"]}", "#{l["blog_id"]}")
          end
        end
      end
 
graph.output(:file => "implict.jpeg" )




