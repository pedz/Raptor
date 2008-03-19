class CreateCachedPmrs < ActiveRecord::Migration
  def self.up
    create_table :cached_pmrs do |t|
      t.string  :problem,         :limit => 5,  :null => false 
      t.string  :branch,          :limit => 3,  :null => false 
      t.string  :country,         :limit => 3,  :null => false
      t.integer :customer_id,                   :null => false
      t.integer :owner_id       # id into Registrations
      t.integer :resolver_id    # id into Registrations
      t.integer :center_id      # id into Centers
      t.integer :queue_id       # id into Queues
      t.integer :primary        # id into Calls
      t.integer :next_center_id # id into Centers
      t.integer :next_queue_id  # id into Queues
      t.integer :severity
      t.string  :component_id,    :limit => 12
      t.string  :problem_e_mail,  :limit => 64
      t.string  :creation_date,   :limit => 9
      t.string  :creation_time,   :limit => 5
      t.string  :alteration_date, :limit => 9
      t.string  :alteration_time, :limit => 5
      #
      # The fields below could be direct references to calls and for
      # the primary, that may be a good idea.  But, for now, I'm going
      # to just leave these fields as raw Retain fields and then add
      # methods to the cached_pmr model to access the primary call and
      # the secondaries.  One reason is I know that Retain can get
      # into weird states with PMRs on a queue that do not show up on
      # the queue, etc.
      #
      t.string  :sec_1_queue,     :limit => 6
      t.string  :sec_1_center,    :limit => 3
      t.string  :sec_1_h_or_s,    :limit => 1
      t.string  :sec_1_ppg,       :limit => 3
      t.string  :sec_2_queue,     :limit => 6
      t.string  :sec_2_center,    :limit => 3
      t.string  :sec_2_h_or_s,    :limit => 1
      t.string  :sec_2_ppg,       :limit => 3
      t.string  :sec_3_queue,     :limit => 6
      t.string  :sec_3_center,    :limit => 3
      t.string  :sec_3_h_or_s,    :limit => 1
      t.string  :sec_3_ppg,       :limit => 3
      t.timestamps 
    end
    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT uq_cached_pmrs_triple
             UNIQUE (problem, branch, country, creation_date)"
    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT fk_cached_pmrs_owner_id
             FOREIGN KEY (owner_id) REFERENCES cached_registrations(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT fk_cached_pmrs_resolver_id
             FOREIGN KEY (resolver_id) REFERENCES cached_registrations(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT fk_cached_pmrs_customer_id
             FOREIGN KEY (customer_id) REFERENCES cached_customers(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :cached_pmrs
  end
end
