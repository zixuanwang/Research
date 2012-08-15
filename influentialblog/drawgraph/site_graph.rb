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
  select site_id, site_name from sites 
SQL

sites = DBConnection::connection.select_all(sql)

graph = GraphViz::new( "G", "output" => "png", "nodesep" => ".1", "rankdir"=>"LR")

sites_array = Array.new
sites_array =["seriouseats/","eater/","nymag.com/daily/food/","dinersjournal.blogs.nytimes.com/","www.nytimes.com/pages/dining/","bitten.blogs.nytimes.com/","blogs.villagevoice.com/forkintheroad/"]

color_array = ["coral","maroon","skyblue","seagreen","orange","orchid","yellow"]
sites.each do |row|
  if row["site_id"] 
    puts row["site_id"]
    graph.add_node("site_#{row["site_id"].to_s}","style"=>"filled", "color"=>"#{color_array[row["site_id"].to_i]}" )
  end
end


sites.each do |row|
  if row["site_id"]
    sites_array.each do |site_name|
      sql=<<-SQL
      select count(distinct link_id) as cnt from blogs, blog_links, info_links where blogs.site_id = #{row["site_id"]} and blogs.blog_id = blog_links.blog_id and info_links.id = blog_links.link_id and info_links.link_url like "%#{site_name}%"
      SQL
      link_count = DBConnection::connection.select_all(sql)[0]
      if !link_count["cnt"].to_i.zero?
        puts("site_#{row["site_id"]}, site_#{sites_array.index(site_name)+1}, #{link_count["cnt"]}")
        length = Math.exp(1.0/3.0*(Math.log(link_count["cnt"].to_i)))
        puts length
        graph.add_edge("site_#{row["site_id"]}", "site_#{sites_array.index(site_name)+1}", "style" => "setlinewidth(#{length.to_i})", "weight"=>"7")
      end
    end
  end
end

graph.output(:file => "#{$0}.jpeg" )




