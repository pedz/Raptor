class CreateCachedComponents < ActiveRecord::Migration
  def self.up
    create_table :cached_components do |t|
      t.string :short_component_id,         :limit => 11, :null => false
      t.string :component_name,             :limit => 19, :null => false
      t.string :release_name,               :limit =>  3, :null => false
      t.string :multiple_change_team_id,    :limit =>  6, :null => false
      t.string :multiple_fe_support_grp_id, :limit =>  6, :null => false
      t.date   :start_date
      t.date   :end_date
      t.timestamps
    end
    execute "ALTER TABLE cached_components ADD CONSTRAINT uq_cached_components_tuple
             UNIQUE (short_component_id, release_name)"
  end

  def self.down
    drop_table :cached_components
  end
end
