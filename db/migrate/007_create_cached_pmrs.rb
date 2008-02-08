class CreateCachedPmrs < ActiveRecord::Migration
  def self.up
    create_table :cached_pmrs do |t|
      t.string  :problem,         :limit => 5, :null => false 
      t.string  :branch,          :limit => 3, :null => false 
      t.string  :country,         :limit => 3, :null => false
      t.string  :severity,        :limit => 1
      t.string  :component_id,    :limit => 12
      t.integer :owner_id       # id into Registrations
      t.integer :resolver_id    # id into Registrations
      t.string  :problem_e_mail,  :limit => 64
      t.string  :next_queue,      :limit => 6
      t.string  :next_center,     :limit => 3
      t.string  :creation_date,   :limit => 9
      t.string  :creation_time,   :limit => 5
      t.string  :alteration_date, :limit => 9
      t.string  :alteration_time, :limit => 5
      t.timestamps 
    end
    execute("ALTER TABLE cached_pmrs ADD CONSTRAINT unique_pmrs " +
            "UNIQUE (problem, branch, country, creation_date)")
  end

  def self.down
    drop_table :cached_pmrs
  end
end
