require "graphviz"
require "rubygems"


class Grouppost < ActiveRecord::Base
  $rails_home=File.join(File.dirname(__FILE__),"../..")
  def self.groupbyname(name)
    st = Array.new
    sql =<<-SQL
      select T.name, T.site_id, T.id, T.publish_date, T.title, T.content, count(distinct blogs_outlinks.outlink_id) as linkcnt, count(distinct comments.id) as comcnt from (select sites.name, site_id, blogs.id, publish_date, title,content from blogs, sites where sites.id = blogs.site_id and title like "%#{name}%")T left join blogs_outlinks on T.id = blogs_outlinks.blog_id left join comments on T.id = comments.blog_id  group by T.id;
    SQL

    if !name.blank?
      status = connection.select_all(sql)
      
      status.each do |s|
        tmp = Hash.new
        tmp["site_id"] = s["site_id"]
        tmp["site_name"] = s["name"]
        tmp["blog_id"] = s["id"]
        tmp["publish_date"] = s["publish_date"]
        tmp["linkcnt"] = s["linkcnt"]
        tmp["comcnt"] = s["comcnt"]
        tmp["title"] = s["title"]
        tmp["length"] = s["content"].length()
        st<<tmp
      end
      return st
    end
  end

  
  def self.sortbypublishdate(name)
    sst = Array.new
    sql =<<-SQL
    select T.site_id, T.name, T.id, T.publish_date, T.title, T.content, count(distinct blogs_outlinks.outlink_id) as linkcnt, count(distinct comments.id) as comcnt from (select site_id, sites.name,title, blogs.id, publish_date, content from blogs,sites where sites.id = blogs.site_id and title like "%#{name}%")T left join blogs_outlinks on T.id = blogs_outlinks.blog_id left join comments on T.id = comments.blog_id  group by T.id order by T.publish_date;
    SQL
    status = connection.select_all(sql)
    
    status.each do |s|
      tmp = Hash.new
      tmp["site_id"] = s["site_id"]
      tmp["site_name"] = s["name"]
      tmp["blog_id"] = s["id"]
      tmp["publish_date"] = s["publish_date"]
      tmp["linkcnt"] = s["linkcnt"]
      tmp["comcnt"] = s["comcnt"]
      tmp["title"] = s["title"]
      tmp["length"] = s["content"].length()
      sst<<tmp
    end
    return sst
  end
  
  def self.sortbylinkcnt(name)
    st = Array.new
    sql =<<-SQL
    select T.site_id, T.name, T.id, T.publish_date, T.title, T.content, count(distinct blogs_outlinks.outlink_id) as linkcnt, count(distinct comments.id) as comcnt from (select site_id, sites.name, blogs.id, publish_date, title, content from blogs,sites where sites.id = blogs.site_id and title like "%#{name}%")T left join blogs_outlinks on T.id = blogs_outlinks.blog_id left join comments on T.id = comments.blog_id  group by T.id order by linkcnt desc;
    SQL
    status = connection.select_all(sql)
    
    status.each do |s|
      tmp = Hash.new
      tmp["site_id"] = s["site_id"]
      tmp["blog_id"] = s["id"]
      tmp["publish_date"] = s["publish_date"]
      tmp["linkcnt"] = s["linkcnt"]
      tmp["comcnt"] = s["comcnt"]
      tmp["title"] = s["title"]
      tmp["length"] = s["content"].length()
      st<<tmp
    end
    return st
  end
  
  def self.sortbycomcnt(name)
    st = Array.new
    sql =<<-SQL
    select T.site_id, T.id, T.publish_date, T.title, T.content, count(distinct blogs_outlinks.outlink_id) as linkcnt, count(distinct comments.id) as comcnt from (select site_id,sites.name, blogs.id, publish_date, title, content from blogs,sites where  sites.id = blogs.site_id and title like "%#{name}%")T left join blogs_outlinks on T.id = blogs_outlinks.blog_id left join comments on T.id = comments.blog_id  group by T.id order by comcnt desc;
    SQL

    status = connection.select_all(sql)
    
    status.each do |s|
      tmp = Hash.new
      tmp["site_id"] = s["site_id"]
      tmp["site_name"]=s["name"]
      tmp["blog_id"] = s["id"]
      tmp["publish_date"] = s["publish_date"]
      tmp["linkcnt"] = s["linkcnt"]
      tmp["comcnt"] = s["comcnt"]
      tmp["title"] = s["title"]
      tmp["length"] = s["content"].length()
      st<<tmp
    end
    return st
  end

  def self.drawgraph(name)
    sql =<<-SQL
    select L.site_id as l_site, L.name as l_name, L.id as l_id, unix_timestamp(date(L.publish_date)) as l_date, P.id as s_id, P.site_id as s_site, sites.name as s_name, unix_timestamp(date(P.publish_date)) as s_date from (select T.site_id, T.name, T.id, T.publish_date, blogs_outlinks.outlink_id from (select site_id, sites.name, blogs.id, publish_date, content from blogs,sites where title like "%#{name}%" and blogs.site_id = sites.id)T left join blogs_outlinks on T.id = blogs_outlinks.blog_id  order by T.publish_date)L, outlinks, blogs P, sites where L.outlink_id = outlinks.id and outlinks.url = P.url and P.site_id = sites.id;
    SQL
    sites = connection.select_all(sql)
    graph = GraphViz::new( "G", "output" => "png", "nodesep" => ".1", "rankdir"=>"LR")
    
    sites_array = Array.new
    sites.each do |row|
      graph.add_node("#{row["s_id"]}", :label => "#{row["s_site"]}:#{row["s_name"]}:#{row["s_id"]}")
      graph.add_node("#{row["l_id"]}", :label => "#{row["l_site"]}:#{row["l_name"]}:#{row["l_id"]}", :fontcolor=>"blue")
      graph.add_edge("#{row["l_id"]}", "#{row["s_id"]}")
    end
    graph.output(:file => "#{$rails_home}/public/images/groupbyname.jpeg" )
  end

  def self.drawimplicitgraph(name)
     sql =<<-SQL
     select site_id,sites.name, blogs.id as blog_id, unix_timestamp(date(publish_date)) as pdate from sites,blogs where title like "%#{name}%" and sites.id = blogs.site_id order by pdate;
     SQL
     sites = connection.select_all(sql)
     nodes = Array.new
     timestr = ""
     sites.each do |row|
       timestr += row["pdate"]
       timestr += " "
       tmp=Hash.new
       tmp["blog_id"] = row["blog_id"]
       tmp["date"] = row["pdate"].to_i
       nodes << tmp
     end
     timestr.strip.gsub!(" ",";")
      
     graph = GraphViz::new("G", "output" => "png", "nodesep" => ".1" )
     
     sites.each do |row|
      graph.add_node("#{row["blog_id"]}", :label => "#{row["site_id"]}:#{row["name"]}:#{row["blog_id"]}")
     end
      
    revnodes = nodes.reverse
    nodes.each do|l|
      revnodes.each do |s|
        if s["date"] > l["date"]
          graph.add_edge("#{s["blog_id"]}", "#{l["blog_id"]}")
        end
      end
    end
    graph.output(:file => "#{$rails_home}/public/images/implicitlinks.jpeg" )
  end
 
 def self.drawcompletegraph(name) 
   puts name 
   if name.nil? or name.empty?
      return
    end
    
    sql =<<-SQL
    select site_id,sites.name, blogs.id as blog_id, unix_timestamp(date(publish_date)) as pdate from sites,blogs where title like "%#{name}%" and sites.id = blogs.site_id order by pdate;
    SQL
    sites = connection.select_all(sql)
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

    refsites = connection.select_all(sql)
    
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
    
    gFile = File.open("#{$rails_home}/public/images/group.dot", "w")
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
 end

  
  def self.showoverlapoutlinks(name)
    sql =<<-SQL 
      select T1.outlink_id as outlinkid, T1.site_id as left_site, T2.site_id as right_site from (select outlink_id, site_id, count(distinct id) as cnt, publish_date from blogs,blogs_outlinks where title like "%#{name}%" and blogs.id = blogs_outlinks.blog_id group by outlink_id,site_id)T1, (select outlink_id, site_id, count(distinct id) from blogs, blogs_outlinks where title like "%#{name}%" and blogs.id = blogs_outlinks.blog_id group by outlink_id,site_id)T2 where T1.outlink_id = T2.outlink_id and T1.site_id < T2.site_id
    SQL
    status = connection.select_all(sql)
    rst = Array.new
    graph = GraphViz::new("G", "output" => "png", "nodesep" => ".1")
    sitearray = Array.new
    nodearray = Array.new

    status.each do |row|
      st = Hash.new
      outlinkid = row["outlinkid"]
      st["outlink_id"] = row["outlinkid"]
      st["left_site"] = row["left_site"] 
      st["right_site"] = row["right_site"]
      rst << st
      if !nodearray.include?(outlinkid)
        nodearray << outlinkid
      end
      if  !sitearray.include?(st["left_site"])
        sitearray << st["left_site"]
      end
      if  !sitearray.include?(st["right_site"])
        sitearray << st["right_site"]
      end
    end
      nodearray.each  do |n|
        graph.add_node("#{n}", :label => "Outlink_#{n.to_s}")
      end

      sitearray.each  do |s|
        graph.add_node("#{s}", :label => "site_#{s.to_s}", :fontcolor => "blue")
      end
   
      rst.each do |r|
        graph.add_edge("#{r["outlink_id"]}", "#{r["left_site"]}")
        graph.add_edge("#{r["outlink_id"]}", "#{r["right_site"]}")
      end

      graph.output(:file => "#{$rails_home}/public/images/overlaplinks.jpeg") 
      return rst
  end
  
end
