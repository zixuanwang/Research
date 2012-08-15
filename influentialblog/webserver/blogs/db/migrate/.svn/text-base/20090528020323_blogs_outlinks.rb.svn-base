class BlogsOutlinks < ActiveRecord::Migration
  def self.up
  create_table(:blogs_outlinks, :id => false) do |t|
    t.integer :blog_id, :null => false
    t.integer :outlink_id, :null => false
  end
  add_index(:blogs_outlinks, [:blog_id,:outlink_id])
  add_index(:blogs_outlinks, [:outlink_id, :blog_id]) 
  end
  

  def self.down
    drop_table :blogs_outlinks
  end
end
