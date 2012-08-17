class Site < ActiveRecord::Base
  has_many :blogs
  
  def self.statistics
    stat=Array.new(40){Hash.new}
   
    sql=<<-SQL
      select sites.id, sites.name, T.cnt, T.mint, T.maxt from sites,(select site_id, count(distinct id) as cnt, max(publish_date) as maxt, min(publish_date) as mint from blogs group by site_id)T where T.site_id = sites.id;
    SQL
    posts = connection.select_all(sql)
    
    posts.each do |l|
      stat[(l["id"].to_i-1)]["posts"]=l["cnt"].to_i
      stat[(l["id"].to_i-1)]["id"] = l["id"].to_i
      stat[(l["id"].to_i-1)]["name"]=l["name"]
      stat[(l["id"].to_i-1)]["from"]=l["mint"]
      stat[(l["id"].to_i-1)]["to"]=l["maxt"]
      stat[(l["id"].to_i-1)]["comments"]=0
      stat[(l["id"].to_i-1)]["outlinks"]=0
      stat[(l["id"].to_i-1)]["selflinks"]=0
      stat[(l["id"].to_i-1)]["inlinks"]=0
    end

    sql=<<-SQL
      select sites.id, count(distinct outlinks.id) as cnt from sites, blogs, blogs_outlinks, outlinks where sites.id = blogs.site_id and blogs.id = blogs_outlinks.blog_id and outlinks.id = blogs_outlinks.outlink_id and outlinks.domain like concat("%", sites.name,"%") group by sites.id;
    SQL
    inlinks = connection.select_all(sql)
    inlinks.each do |l|
      stat[(l["id"].to_i-1)]["selflinks"]=l["cnt"].to_i
    end
    
    sql=<<-SQL
      select site_id, count(distinct blogs_outlinks.blog_id) as cnt from blogs, blogs_outlinks, outlinks where blogs.url = outlinks.url and outlinks.id = blogs_outlinks.outlink_id group by blogs.site_id
    SQL
    inlinks = connection.select_all(sql)
    inlinks.each do |l|
      stat[(l["site_id"].to_i-1)]["inlinks"]=l["cnt"].to_i
    end
    
    sql=<<-SQL
      select blogs.site_id, count(distinct blogs_outlinks.outlink_id) as cnt from blogs, blogs_outlinks where blogs.id = blogs_outlinks.blog_id group by blogs.site_id;
    SQL
    outlinks = connection.select_all(sql)

    outlinks.each do |l|
      
      stat[(l["site_id"].to_i-1)]["outlinks"]=l["cnt"].to_i
    end

    sql=<<-SQL
      select site_id, count(distinct comments.id) as cnt from blogs, comments where blogs.id = comments.blog_id group by site_id;
    SQL
    comments = connection.select_all(sql)

    comments.each do |l|
      stat[(l["site_id"].to_i-1)]["comments"]=l["cnt"].to_i
    end
    
   return stat
  end
end