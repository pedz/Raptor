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

ActiveRecord::Schema.define(:version => 18) do

  create_table "cached_calls", :force => true do |t|
    t.integer  "queue_id",                         :null => false
    t.string   "ppg",                :limit => 3,  :null => false
    t.integer  "pmr_id",                           :null => false
    t.integer  "priority"
    t.string   "p_s_b",              :limit => 1
    t.string   "comments",           :limit => 54
    t.string   "nls_customer_name",  :limit => 28
    t.string   "nls_contact_name",   :limit => 30
    t.string   "contact_phone_1",    :limit => 19
    t.string   "contact_phone_2",    :limit => 19
    t.string   "cstatus",            :limit => 7
    t.string   "category",           :limit => 3
    t.boolean  "system_down"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "slot"
    t.binary   "call_search_result"
    t.boolean  "dirty"
  end

  add_index "cached_calls", ["queue_id", "ppg"], :name => "uq_cached_calls_pair", :unique => true

  create_table "cached_centers", :force => true do |t|
    t.string   "center",                    :limit => 3, :null => false
    t.string   "software_center_mnemonic",  :limit => 3
    t.string   "center_daylight_time_flag", :limit => 1
    t.integer  "delay_to_time"
    t.integer  "minutes_from_gmt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cached_centers", ["center"], :name => "uq_cached_centers", :unique => true

  create_table "cached_customers", :force => true do |t|
    t.string   "country",            :limit => 3,  :null => false
    t.string   "customer_number",    :limit => 7,  :null => false
    t.integer  "center_id"
    t.string   "company_name",       :limit => 36
    t.boolean  "daylight_time_flag"
    t.string   "time_zone",          :limit => 5
    t.integer  "time_zone_binary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cached_customers", ["country", "customer_number"], :name => "uq_cached_customers_pair", :unique => true

  create_table "cached_pmrs", :force => true do |t|
    t.string   "problem",              :limit => 5,  :null => false
    t.string   "branch",               :limit => 3,  :null => false
    t.string   "country",              :limit => 3,  :null => false
    t.integer  "customer_id",                        :null => false
    t.integer  "owner_id"
    t.integer  "resolver_id"
    t.integer  "center_id"
    t.integer  "queue_id"
    t.integer  "primary"
    t.integer  "next_center_id"
    t.integer  "next_queue_id"
    t.integer  "severity"
    t.string   "component_id",         :limit => 12
    t.string   "problem_e_mail",       :limit => 64
    t.string   "creation_date",        :limit => 9
    t.string   "creation_time",        :limit => 5
    t.string   "alteration_date",      :limit => 9
    t.string   "alteration_time",      :limit => 5
    t.string   "sec_1_queue",          :limit => 6
    t.string   "sec_1_center",         :limit => 3
    t.string   "sec_1_h_or_s",         :limit => 1
    t.string   "sec_1_ppg",            :limit => 3
    t.string   "sec_2_queue",          :limit => 6
    t.string   "sec_2_center",         :limit => 3
    t.string   "sec_2_h_or_s",         :limit => 1
    t.string   "sec_2_ppg",            :limit => 3
    t.string   "sec_3_queue",          :limit => 6
    t.string   "sec_3_center",         :limit => 3
    t.string   "sec_3_h_or_s",         :limit => 1
    t.string   "sec_3_ppg",            :limit => 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "last_alter_timestamp"
    t.boolean  "dirty"
  end

  add_index "cached_pmrs", ["problem", "branch", "country", "creation_date"], :name => "uq_cached_pmrs_triple", :unique => true

  create_table "cached_psars", :force => true do |t|
    t.integer  "pmr_id"
    t.integer  "apar_id"
    t.integer  "queue_id"
    t.string   "signon2",                 :limit => 6
    t.integer  "chargeable_time_hex"
    t.string   "cpu_serial_number",       :limit => 7
    t.string   "cpu_type",                :limit => 4
    t.integer  "minutes_from_gmt"
    t.integer  "psar_action_code"
    t.string   "psar_activity_date",      :limit => 4
    t.string   "psar_activity_stop_time", :limit => 3
    t.integer  "psar_actual_time"
    t.integer  "psar_cause"
    t.string   "psar_chargeable_src_ind", :limit => 1
    t.integer  "psar_chargeable_time"
    t.string   "psar_cia",                :limit => 1
    t.string   "psar_fesn",               :limit => 7
    t.string   "psar_file_and_symbol",    :limit => 20
    t.integer  "psar_impact"
    t.string   "psar_mailed_flag",        :limit => 1
    t.string   "psar_sequence_number",    :limit => 5
    t.integer  "psar_service_code"
    t.string   "psar_solution",           :limit => 1
    t.string   "psar_stop_date_year",     :limit => 2
    t.string   "psar_system_date",        :limit => 6
    t.integer  "stop_time_moc"
    t.boolean  "dirty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cached_queue_infos", :force => true do |t|
    t.integer  "queue_id",   :null => false
    t.integer  "owner_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cached_queue_infos", ["queue_id", "owner_id"], :name => "uq_cached_queue_infos_queue_owner", :unique => true

  create_table "cached_queues", :force => true do |t|
    t.string   "queue_name", :limit => 6, :null => false
    t.string   "h_or_s",     :limit => 1, :null => false
    t.integer  "center_id",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "dirty"
  end

  add_index "cached_queues", ["queue_name", "h_or_s", "center_id"], :name => "uq_cached_queues_triple", :unique => true

  create_table "cached_registrations", :force => true do |t|
    t.string   "signon",                :null => false
    t.integer  "software_center_id"
    t.integer  "hardware_center_id"
    t.string   "psar_number"
    t.string   "name"
    t.string   "telephone_number"
    t.boolean  "daylight_savings_time"
    t.integer  "time_zone_adjustment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cached_registrations", ["signon"], :name => "uq_cached_registrations_signon", :unique => true

  create_table "cached_text_lines", :force => true do |t|
    t.integer  "pmr_id",                      :null => false
    t.integer  "line_type",                   :null => false
    t.integer  "line_number",                 :null => false
    t.integer  "text_type_ord",               :null => false
    t.string   "text",          :limit => 72, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cached_text_lines", ["pmr_id", "line_type", "line_number"], :name => "uq_cached_text_lines_triple", :unique => true

  create_table "favorite_queues", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "queue_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorite_queues", ["user_id", "queue_id"], :name => "uq_favorite_queues", :unique => true

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

  create_table "retusers", :force => true do |t|
    t.integer  "user_id"
    t.string   "retid",                         :null => false
    t.string   "password",                      :null => false
    t.boolean  "failed",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "retusers", ["retid"], :name => "uq_retusers_retid", :unique => true
  add_index "retusers", ["user_id"], :name => "uq_retusers_user_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "ldap_id",                       :null => false
    t.boolean  "admin",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["ldap_id"], :name => "uq_ldap_id", :unique => true

end
