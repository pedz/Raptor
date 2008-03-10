class AddQueueCenterToCachedPmrs < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :queue_name,   :string, :limit => 6
    add_column :cached_pmrs, :center,       :string, :limit => 3
    add_column :cached_pmrs, :h_or_s,       :string, :limit => 1
    add_column :cached_pmrs, :ppg,          :string, :limit => 3
    add_column :cached_pmrs, :sec_1_queue,  :string, :limit => 6
    add_column :cached_pmrs, :sec_1_center, :string, :limit => 3
    add_column :cached_pmrs, :sec_1_h_or_s, :string, :limit => 1
    add_column :cached_pmrs, :sec_1_ppg,    :string, :limit => 3
    add_column :cached_pmrs, :sec_2_queue,  :string, :limit => 6
    add_column :cached_pmrs, :sec_2_center, :string, :limit => 3
    add_column :cached_pmrs, :sec_2_h_or_s, :string, :limit => 1
    add_column :cached_pmrs, :sec_2_ppg,    :string, :limit => 3
    add_column :cached_pmrs, :sec_3_queue,  :string, :limit => 6
    add_column :cached_pmrs, :sec_3_center, :string, :limit => 3
    add_column :cached_pmrs, :sec_3_h_or_s, :string, :limit => 1
    add_column :cached_pmrs, :sec_3_ppg,    :string, :limit => 3
  end

  def self.down
    remove_column :cached_pmrs, :sec_3_ppg
    remove_column :cached_pmrs, :sec_3_h_or_s
    remove_column :cached_pmrs, :sec_3_center
    remove_column :cached_pmrs, :sec_3_queue
    remove_column :cached_pmrs, :sec_2_ppg
    remove_column :cached_pmrs, :sec_2_h_or_s
    remove_column :cached_pmrs, :sec_2_center
    remove_column :cached_pmrs, :sec_2_queue
    remove_column :cached_pmrs, :sec_1_ppg
    remove_column :cached_pmrs, :sec_1_h_or_s
    remove_column :cached_pmrs, :sec_1_center
    remove_column :cached_pmrs, :sec_1_queue
    remove_column :cached_pmrs, :ppg
    remove_column :cached_pmrs, :h_or_s
    remove_column :cached_pmrs, :center
    remove_column :cached_pmrs, :queue_name
  end
end
