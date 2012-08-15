class Popmeasure < ActiveRecord::Base
  def self.orderpopbysite(days)
    st = Array.new
    sql =<<-SQL
      select blogs.site_id, count(distinct comments.id)as cnt from blogs, comments where blogs.id=comments.blog_id and datediff(comments.publish_date,blogs.publish_date) < #{days} group by blogs.site_id order by cnt desc;
    SQL
    status = connection.select_all(sql)
    
    sql =<<-SQL
      select site_id, count(distinct comments.id) as cnt from blogs,comments where blogs.id = comments.blog_id group by site_id;
    SQL
    siteinfo = connection.select_all(sql)
    sitehash = Hash.new(40)
    siteinfo.each do|si|
      sitehash["#{si["site_id"]}"] = si["cnt"]
    end
    
    sql =<<-SQL
      select blogs.site_id, count(distinct comments.id)as cnt from blogs, comments where blogs.id=comments.blog_id and datediff(comments.publish_date,blogs.publish_date)>30 group by blogs.site_id order by cnt desc;
    SQL
    largestatus = connection.select_all(sql)
    large = Hash.new(40)
    largestatus.each do |l|
      large["#{l["site_id"]}"]=l["cnt"]
    end

    status.each do |s|
      tmp = Hash.new
      tmp["site_id"] = s["site_id"]
      tmp["comcnt"] = sitehash["#{s["site_id"]}"]
      tmp["lesscnt"] = s["cnt"]
      tmp["lessratio"] = "%0.2f" %  (tmp["lesscnt"].to_f/tmp["comcnt"].to_f)
      tmp["largecnt"] = large["#{s["site_id"]}"]
      tmp["largeratio"]= "%0.3f" % (tmp["largecnt"].to_f/tmp["comcnt"].to_f)
      st<<tmp
    end
    return st
  end
   
end
