class CreateOutlinks < ActiveRecord::Migration
  def self.up
    create_table :outlinks do |t|
      t.text :url
      t.string :domain
      t.timestamps
    end
    
    sql=<<-SQL
      create index index_outlinks_on_url_id on outlinks(url(300),id)
    SQL
    execute(sql)
  end

  def self.down
    drop_table :outlinks
  end
end
