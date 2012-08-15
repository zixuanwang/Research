# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090712215542) do

  create_table "blogs", :force => true do |t|
    t.integer  "site_id"
    t.text     "url"
    t.string   "title"
    t.string   "author"
    t.datetime "publish_date"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blogs", ["site_id"], :name => "index_blogs_on_site_id"
  add_index "blogs", ["url"], :name => "index_blogs_on_url"

  create_table "blogs_outlinks", :id => false, :force => true do |t|
    t.integer "blog_id",    :null => false
    t.integer "outlink_id", :null => false
  end

  add_index "blogs_outlinks", ["blog_id", "outlink_id"], :name => "index_blogs_outlinks_on_blog_id_and_outlink_id"
  add_index "blogs_outlinks", ["outlink_id", "blog_id"], :name => "index_blogs_outlinks_on_outlink_id_and_blog_id"

  create_table "comments", :force => true do |t|
    t.integer  "blog_id"
    t.string   "author"
    t.datetime "publish_date"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["blog_id"], :name => "index_comments_on_blog_id"

  create_table "outlinks", :force => true do |t|
    t.text     "url"
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outlinks", ["url", "id"], :name => "index_outlinks_on_url_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.text     "url"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
