class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :blog_id
      t.string :author
      t.timestamp :publish_date
      t.text :content
      t.timestamps
    end

    add_index(:comments, [:blog_id])
  
  end

  def self.down
    drop_table :comments
  end
end
