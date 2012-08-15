require "rubygems"


class Searchpost < ActiveRecord::Base
  def self.searchsitebyid(site_id)
    sql =<<-SQL
      select id, url from sites where id = #{site_id}
    SQL
    status = connection.select_all(sql)    
    st = Hash.new
    st["site_id"] = status[0]["id"]
    st["site_url"] = status[0]["url"]
    return st
  end
  
  def self.searchlinkbyid(link_id)
    st=Hash.new
    sql =<<-SQL
      select id, url, domain from outlinks where id = #{link_id.to_i}
    SQL
    status = connection.select_all(sql)
    st["link_url"] = status[0]["url"] 
    st["link_id"] = status[0]["id"]
    st["domain"] = status[0]["domain"]
    sql =<<-SQL
      select site_id, id, publish_date from blogs, blogs_outlinks where blogs.id = blogs_outlinks.blog_id and blogs_outlinks.outlink_id = #{link_id.to_i} order by publish_date 
    SQL
    bstatus = connection.select_all(sql)
    tarray = Array.new
    bstatus.each do |b|
      thash = Hash.new
      thash["site_id"] = b["site_id"]
      thash["blog_id"] = b["id"]
      thash["blog_time"] = b["publish_date"]
      tarray << thash
    end
    st["blogs"] = tarray
    return st
  end
  
  def self.searchpostbyid(blog_id)
    st = Hash.new
    sql =<<-SQL
      select url, site_id, id, title, publish_date, content from blogs where id = #{blog_id.to_i}
    SQL
    status = connection.select_all(sql)
    st["url"] = status[0]["url"]
    st["site_id"] = status[0]["site_id"] 
    st["blog_id"] = status[0]["id"]
    st["title"] = status[0]["title"]
    st["publish_date"] = status[0]["publish_date"]
    st["content"] = status[0]["content"] 
    st["length"] = st["content"].length()

    sql =<<-SQL
      select count(distinct outlink_id) as cnt from blogs_outlinks where blog_id = #{blog_id}
    SQL
    lstatus = connection.select_all(sql)
    st["outlink_cnt"] = lstatus[0]["cnt"]
    
    sql =<<-SQL
      select url from blogs_outlinks, outlinks where blog_id = #{blog_id} and outlinks.id = blogs_outlinks.outlink_id
    SQL
    lurl = connection.select_all(sql)
    st["outlinks"]=Array.new
    lurl.each do |row|
      st["outlinks"] << row["url"]
    end

    sql =<<-SQL
      select count(distinct id) as cnt from comments  where blog_id = #{blog_id}
    SQL
    cstatus = connection.select_all(sql)
    st["comment_cnt"] = cstatus[0]["cnt"]
    return st
  end
  
  def self.searchpostbyurl(blog_url)
    url = blog_url.strip
    sql =<<-SQL
      select url, site_id, id, title, publish_date, content from blogs where url = "#{url}"
    SQL
    
    status = connection.select_all(sql)
    st = Hash.new 
    st["url"] = status[0]["url"]
    st["site_id"] = status[0]["site_id"] 
    st["blog_id"] = status[0]["id"]
    st["title"] = status[0]["title"]
    st["publish_date"] = status[0]["publish_date"]
    st["content"] = status[0]["content"] 
    st["length"] = st["content"].length()

    sql =<<-SQL
        select count(distinct outlink_id) as cnt from blogs_outlinks where blog_id = #{st["blog_id"]}
    SQL
    lstatus = connection.select_all(sql)
    st["outlink_cnt"] = lstatus[0]["cnt"]
      
    sql =<<-SQL
      select url from blogs_outlinks, outlinks where blogs_outlinks.blog_id = #{st["blog_id"]} and outlinks.id = blogs_outlinks.outlink_id
    SQL
    lurl = connection.select_all(sql)
    st["outlinks"]=Array.new
    lurl.each do |row|
      st["outlinks"] << row["url"]
    end
    sql =<<-SQL
      select count(distinct id) as cnt from comments  where blog_id = #{st["blog_id"]}
    SQL
    cstatus = connection.select_all(sql)
    st["comment_cnt"] = cstatus[0]["cnt"]
  
    return st
  
  end
 
end
