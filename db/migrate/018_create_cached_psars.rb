class CreateCachedPsars < ActiveRecord::Migration
  def self.up
    create_table :cached_psars do |t|
      t.integer :pmr_id
      t.integer :apar_id
      t.integer :queue_id
      t.string  :signon2,                 :limit => 6
      t.integer :chargeable_time_hex
      t.string  :cpu_serial_number,       :limit => 7
      t.string  :cpu_type,                :limit => 4
      t.integer :minutes_from_gmt
      t.integer :psar_action_code
      t.string  :psar_activity_date,      :limit => 4
      t.string  :psar_activity_stop_time, :limit => 3
      t.integer :psar_actual_time
      t.integer :psar_cause
      t.string  :psar_chargeable_src_ind, :limit => 1
      t.integer :psar_chargeable_time
      t.string  :psar_cia,                :limit => 1
      t.string  :psar_fesn,               :limit => 7
      t.string  :psar_file_and_symbol,    :limit => 20
      t.integer :psar_impact
      t.string  :psar_mailed_flag,        :limit => 1
      t.string  :psar_sequence_number,    :limit => 5
      t.integer :psar_service_code
      t.string  :psar_solution,           :limit => 1
      t.string  :psar_stop_date_year,     :limit => 2
      t.string  :psar_system_date,        :limit => 6
      t.integer :stop_time_moc
      t.boolean :dirty

      t.timestamps
    end
  end

  def self.down
    drop_table :cached_psars
  end
end
