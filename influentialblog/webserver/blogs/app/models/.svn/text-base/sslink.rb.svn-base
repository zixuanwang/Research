require "graphviz"
class Sslink < ActiveRecord::Base
  def self.statistics
    ss = Array.new
    sql =<<-SQL
      select blogs.site_id, count(distinct blogs_outlinks.outlink_id) as cnt, sites.id from blogs,blogs_outlinks, outlinks,sites where blogs.id = blogs_outlinks.blog_id and blogs_outlinks.outlink_id= outlinks.id and blogs.site_id<>sites.id and outlinks.domain like concat("%",sites.name,"%") group by blogs.site_id, sites.id;
    SQL
    status = connection.select_all(sql)
    
    sql =<<-SQL
      select name, site_id, count(distinct blogs.id) as cnt from blogs,sites where sites.id = blogs.site_id group by blogs.site_id
    SQL
    
    site = connection.select_all(sql)
    blogcount = Hash.new(40)
    sitename = Hash.new(40)
    site.each do |s|
      blogcount["#{s["site_id"]}"] = s["cnt"]
      s["name"]=s["name"].gsub(/-/, "")
      s["name"]=s["name"].gsub(".","")
      sitename["#{s["site_id"]}"] = s["name"]
    end
    
    status.each do |l|
      t=Hash.new
      t["fromsite"] = l["site_id"]
      t["fromname"] = sitename["#{l["site_id"]}"]
      t["tosite"] = l["id"]
      t["toname"] = sitename["#{l["id"]}"]
      t["outlinks"] = l["cnt"]
      t["fromsiteblogs"] = blogcount["#{t["fromsite"]}"]
      t["ratio"] = 0.0
      t["ratio"] = t["outlinks"].to_f/t["fromsiteblogs"].to_f
      ss<<t
    end

    graph = GraphViz::new( "G", "output" => "png", "nodesep" => ".1", "rankdir"=>"LR")
    ss.each do |row|
      connectivity = row["ratio"]*100.to_i
      if connectivity > 4
        case connectivity 
        when 1..9
          thickness = 0
          color = "black"
        when 10..19
          thickness = 1
          color = "blue"
        when 20..30
          thickness = 2
          color = "green"
        when 31..50
          thickness = 3
          color = "orange"
        when 51..150
          thickness = 4
          color = "red"
        end
        graph.add_edge("#{sitename["#{row["fromsite"]}"]}", "#{sitename["#{row["tosite"]}"]}", "style" => "setlinewidth(#{thickness})", "color" => "#{color}")
      end
    end
    graph.output(:file => "#{File.join(File.dirname(__FILE__), '..', '..')}/public/images/site_site_outlinks.jpeg" )
    
    return ss
  end
end
