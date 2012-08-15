class ImportAll < ActiveRecord::Migration
  def self.up
  sql =<<-SQL
    insert into sites(id, url, name) select id, url, name from Weblog.sites
  SQL
  execute(sql)
  
  sql =<<-SQL
    insert into blogs(id,site_id, url, title, author, publish_date, content) select id, site_id, url, title, author, publish_date, content from Weblog.blogs
  SQL
  execute(sql)
  end

  sql =<<-SQL
    insert into outlinks(id, url, domain) select id, url, domain from Weblog.outlinks
  SQL
  execute(sql)

  sql =<<-SQL
    insert into comments(id, blog_id, author, publish_date, content) select id, blog_id, author, publish_date, content from Weblog.comments
  SQL
  execute(sql)
  
  sql =<<-SQL
    insert into blogs_outlinks(blog_id, outlink_id) select blog_id, outlink_id from Weblog.blogs_outlinks
  SQL
  execute(sql)
  
  def self.down
  Site.delete_all
  Blog.delete_all
  Outlink.delete_all
  Comment.delete_all
  sql =<<-SQL
    delete from blogs_outlinks
  SQL
  execute(sql)
  end
end
