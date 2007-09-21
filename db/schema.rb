# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 8) do

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
    t.integer  "user_id",    :null => false
    t.string   "queue_name", :null => false
    t.string   "center",     :null => false
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
    t.string   "retid",      :null => false
    t.string   "password",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "ldap_id",                           :null => false
    t.integer  "retain_user_id"
    t.boolean  "admin",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["ldap_id"], :name => "unique_ldap_id", :unique => true

end
