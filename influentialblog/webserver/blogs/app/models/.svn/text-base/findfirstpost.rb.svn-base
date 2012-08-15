class Findfirstpost < ActiveRecord::Base
  def self.searchbylist(rests)
    st = Array.new
    lrest = Array.new
    lrest = rests.split(",")
    lrest.each do |name|
      sql =<<-SQL
      select T.site_id, T.id, T.publish_date, T.title, T.content, count(distinct blogs_outlinks.outlink_id) as linkcnt, count(distinct comments.id) as comcnt from (select site_id, title,id, publish_date, content from blogs where title like "%#{name}%")T left join blogs_outlinks on T.id = blogs_outlinks.blog_id left join comments on T.id = comments.blog_id  group by T.id order by T.publish_date limit 0,1;
      SQL
      status = connection.select_all(sql)
      tmp = Hash.new
      tmp["rest_name"]= name
      tmp["site_id"] = status[0]["site_id"]
      tmp["blog_id"] = status[0]["id"]
      tmp["publish_date"] = status[0]["publish_date"]
      tmp["linkcnt"] = status[0]["linkcnt"]
      tmp["comcnt"] = status[0]["comcnt"]
      tmp["title"] = status[0]["title"]
      tmp["length"] = status[0]["content"].length
      st<<tmp
    end
   return st 
  end
end
