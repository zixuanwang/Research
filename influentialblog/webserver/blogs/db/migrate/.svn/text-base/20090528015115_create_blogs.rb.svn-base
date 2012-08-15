class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.integer :site_id 
      t.text :url
      t.string :title
      t.string :author
      t.timestamp :publish_date 
      t.text :content
      t.timestamps
    end
    sql=<<-SQL
      create index index_blogs_on_url on blogs(url(300))
    SQL
    execute(sql)

    add_index(:blogs, [:site_id]) 
  
  end

  def self.down
    drop_table :blogs
  end
end
