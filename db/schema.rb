# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 3) do

  create_table "retain_queues", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "queue_name", :null => false
    t.string   "center",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "retain_users", :force => true do |t|
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

end
