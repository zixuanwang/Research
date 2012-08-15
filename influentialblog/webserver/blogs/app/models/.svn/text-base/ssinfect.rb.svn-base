class Ssinfect < ActiveRecord::Base
  
  def self.statistics
    ss = Array.new
    sql =<<-SQL
    select b.site_id  as sa, b2.site_id as sb, (avg(unix_timestamp(b.publish_date)-unix_timestamp(b2.publish_date)))/3600/24 as st from blogs b, blogs_outlinks bo, blogs b2, outlinks o  where b.id = bo.blog_id  and bo.outlink_id = o.id  and o.url = b2.url and b.site_id <> b2.site_id group by b.site_id, b2.site_id;
    SQL
    status = connection.select_all(sql)
    status.each do |l|
      t=Hash.new
      t["fromsite"] = l["sa"]
      t["tosite"]=l["sb"]
      t["time"]=l["st"]
      ss<<t
    end
    return ss
  end
end
