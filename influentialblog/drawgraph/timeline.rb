require "rubygems"
require "graphviz"
require "activerecord"

#connect to mysql
class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",                         
                                  :host => "ursa.rutgers.edu",
                                  :username => "root",                         
                                  :password => "",
                                  :database => "Weblog")


graph = nil
if ARGV[0]
  graph = GraphViz::new( "G", "output" => "png", "nodesep" => ".05", "rankdir" => ARGV[0], "path" => "TB" )
else
  graph = GraphViz::new( "G", "output" => "png", "nodesep" => ".05", "rankdir" => "TB", "path" => "TB" )
end

graph["compound"] = "true"
graph.edge["lhead"] = ""
graph.edge["ltail"] = ""

i=1
while i < 30
  blog_id = i
  c0 = graph.add_graph( "cluster_#{blog_id.to_s}" )
  node0 = c0.add_node("blog_#{blog_id.to_s}")

  sql=<<-SQL
    select link_id from outlinks where blog_id =  #{blog_id}
  SQL
  links = DBConnection::connection.select_all(sql)
  if !links.empty?
    links.each do |row|
      node_t = c0.add_node("link_#{row["link_id"].to_s}")
      c0.add_edge(node0, node_t)
    end
  end
i+=1
end # end for while i < 3

graph.output( :file => "#{$0}.png" )   
    


