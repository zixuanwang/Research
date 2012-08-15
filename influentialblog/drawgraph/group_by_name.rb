require "rubygems"
require "graphviz"
require "activerecord"

class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",                         
                                  :host => "pierce.rutgers.edu",
                                  :username => "root",                         
                                  :password => "",
                                  :database => "Weblog")

name = ARGV[0]

sql =<<-SQL
select S.site_id as tosite, S.id as toid, S.publish_date, P.id as fromid, P.site_id as fromsite from (select T.site_id, T.id, T.publish_date, blogs_outlinks.outlink_id from (select site_id, id, publish_date, content from blogs where title like "%#{name}%")T left join blogs_outlinks on T.id = blogs_outlinks.blog_id  order by T.publish_date)S, outlinks, blogs P where S.outlink_id = outlinks.id and outlinks.url = P.url;
SQL

sites = DBConnection::connection.select_all(sql)

graph = GraphViz::new( "G", "output" => "png", "nodesep" => ".1", "rankdir"=>"LR")

sites_array = Array.new

sites.each do |row|
  graph.add_node("#{row["fromid"]}", :label => "#{row["fromsite"]}:#{row["fromid"]}")
  graph.add_node("#{row["toid"]}", :label => "#{row["tosite"]}:#{row["toid"]}", :fillcolor=>"#116611", :fontcolor=>"blue")
  graph.add_edge("#{row["fromid"]}", "#{row["toid"]}")
end

graph.output(:file => "groupbyname.jpeg" )




