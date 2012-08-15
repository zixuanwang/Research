class Restaurant < ActiveRecord::Base
  def self.showall
    stat = Array.new()
    sql =<<-SQL
      select id, name, category from restaurants 
    SQL
    rests = connection.select_all(sql)
    rests.each do |k|
      tmp = Hash.new
      tmp["id"] = k["id"]
      tmp["name"]= k["name"]
      tmp["category"] = k["category"]
      stat << tmp
    end
    return stat
  end

  def self.showcoverage
    stat = Array.new()
    sql =<<-SQL
      select rests_blogs.site_id, site_name, count(distinct rest_name) as restcnt, 100*count(distinct blog_id)/T.cnt as blogpercent from rests_blogs, (select site_id, count(distinct blogs.id) as cnt from blogs, sites where sites.id = blogs.site_id group by site_id)T where T.site_id = rests_blogs.site_id group by rests_blogs.site_id order by restcnt desc;
    SQL
    rests = connection.select_all(sql)
    rests.each do |row|
      tmp = Hash.new
      tmp["id"] = row["site_id"]
      tmp["site"] = row["site_name"]
      tmp["rests"] = row["restcnt"]
      tmp["percent"] = row["blogpercent"]
      stat << tmp
    end
    return stat
  end
end
