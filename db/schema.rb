# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 11) do

  create_table "cached_calls", :force => true do |t|
    t.string   "queue_name", :limit => 6,                  :null => false
    t.string   "center",     :limit => 3,                  :null => false
    t.string   "h_or_s",     :limit => 1, :default => "S", :null => false
    t.string   "ppg",        :limit => 3,                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cached_pmrs", :force => true do |t|
    t.string   "problem",    :limit => 5, :null => false
    t.string   "branch",     :limit => 3, :null => false
    t.string   "country",    :limit => 3, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cached_queues", :force => true do |t|
    t.string   "queue_name", :limit => 6,                  :null => false
    t.string   "center",     :limit => 3,                  :null => false
    t.string   "h_or_s",     :limit => 1, :default => "S", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cached_text_lines", :force => true do |t|
    t.integer  "cached_pmr_id",               :null => false
    t.integer  "line_number",                 :null => false
    t.integer  "line_type",                   :null => false
    t.string   "text",          :limit => 72, :null => false
    t.integer  "code_page",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorite_queues", :force => true do |t|
    t.integer  "user_id",                     :null => false
    t.string   "queue_name",                  :null => false
    t.string   "center",                      :null => false
    t.string   "h_or_s",     :default => "S"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedback_notes", :force => true do |t|
    t.integer  "feedback_id"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", :force => true do |t|
    t.string   "abstract"
    t.integer  "priority",   :default => 3
    t.integer  "ftype",      :default => 0
    t.integer  "state",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "queue_infos", :force => true do |t|
    t.string   "queue_name"
    t.string   "center"
    t.string   "owner"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "retain_pmrs", :force => true do |t|
    t.string   "problem"
    t.string   "branch"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "retusers", :force => true do |t|
    t.integer  "user_id"
    t.string   "retid",                         :null => false
    t.string   "password",                      :null => false
    t.boolean  "failed",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "ldap_id",                       :null => false
    t.boolean  "admin",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["ldap_id"], :name => "unique_ldap_id", :unique => true

end
