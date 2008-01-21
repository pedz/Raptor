class CreateCachedPmrs < ActiveRecord::Migration
  def self.up
    create_table :cached_pmrs do |t|
      t.string :problem,                   :limit => 5, :null => false 
      t.string :branch,                    :limit => 3, :null => false 
      t.string :country,                   :limit => 3, :null => false
      t.string :severity,                  :limit => 1
      t.string :component_id,              :limit => 12
      t.string :nls_scratch_pad_1,         :limit => 74
      t.string :nls_scratch_pad_2,         :limit => 74
      t.string :nls_scratch_pad_3,         :limit => 74
      t.string :pmr_owner_name,            :limit => 22
      t.string :pmr_owner_employee_number, :limit => 6
      t.string :resolver_id,               :limit => 6
      t.string :resolver_name,             :limit => 22
      t.string :problem_e_mail,            :limit => 64
      t.string :next_queue,                :limit => 6
      t.string :next_center,               :limit => 3
      t.timestamps 
    end
  end

  def self.down
    drop_table :cached_pmrs
  end
end
