class CreateCachedTextLines < ActiveRecord::Migration
  def self.up
    create_table :cached_text_lines do |t|
      t.integer :pmr_id,        :null => false
      t.integer :line_number,   :null => false
      t.integer :line_type,     :null => false
      t.string  :text,          :null => false, :limit => 72
      t.integer :code_page,     :null => false
      t.timestamps 
    end
    execute("ALTER TABLE cached_text_lines ADD CONSTRAINT unique_text_lines " +
            "UNIQUE (pmr_id, line_number)")
  end

  def self.down
    drop_table :cached_text_lines
  end
end
