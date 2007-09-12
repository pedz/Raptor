class CreateCachedTextLines < ActiveRecord::Migration
  def self.up
    create_table :cached_text_lines do |t|
      t.integer :cached_pmr_id, :null => false
      t.integer :line_number,   :null => false
      t.integer :line_type,     :null => false
      t.string  :text,          :null => false, :limit => 72
      t.timestamps 
    end
  end

  def self.down
    drop_table :cached_text_lines
  end
end
