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

sql =<<-SQL
  select blogs.site_id, sites.id, count(distinct blogs_outlinks.outlink_id) as cnt from blogs,blogs_outlinks, outlinks,sites where blogs.id = blogs_outlinks.blog_id and blogs_outlinks.outlink_id= outlinks.id and blogs.site_id <> sites.id and outlinks.domain like concat("%",sites.name,"%") group by blogs.site_id, sites.id  
SQL

sites = DBConnection::connection.select_all(sql)

graph = GraphViz::new( "G", "output" => "png", "nodesep" => ".1", "rankdir"=>"LR")

sites_array = Array.new

sites.each do |row|
    case row["cnt"].to_i
    when 1..9
      thickness = 1
    when 10..99
      thickness = 2
    when 100..199
      thickness = 3
    when 200..299
      thickness = 4
    when 300..1000
      thickness = 5
    end
    graph.add_edge("site_#{row["site_id"]}", "site_#{row["id"]}", "style" => "setlinewidth(#{thickness})")
end

graph.output(:file => "site_site_links.jpeg" )




