class CreateCombinedPsars < ActiveRecord::Migration
  def self.up
    create_table :combined_psars do |t|
      t.integer :pmr_id
      t.integer :apar_id
      t.integer :queue_id
      t.integer :chargeable_time_hex
      t.string :cpu_serial_number
      t.string :cpu_type
      t.integer :minutes_from_gmt
      t.integer :psar_action_code
      t.string :psar_activity_date
      t.string :psar_activity_stop_time
      t.integer :psar_actual_time
      t.integer :psar_cause
      t.string :psar_chargeable_src_ind
      t.integer :psar_chargeable_time
      t.string :psar_cia
      t.string :psar_fesn
      t.string :psar_file_and_symbol
      t.integer :psar_impact
      t.string :psar_mailed_flag
      t.string :psar_sequence_number
      t.integer :psar_service_code
      t.string :psar_solution
      t.string :psar_stop_date_year
      t.string :psar_system_date
      t.integer :stop_time_moc
      t.boolean :dirty

      t.timestamps
    end
  end

  def self.down
    drop_table :combined_psars
  end
end
