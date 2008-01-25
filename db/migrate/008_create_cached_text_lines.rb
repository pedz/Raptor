# A PMR has text lines, signature lines, scratch pad lines, FA lines,
# etc.  All of those lines are kept here.  The common characteristic
# is that they are 72 characters long.
#
# +pmr_id+, +line_type+, +line_number+ should be unique.
#
# +pmr_id+::        +integer+ -- PMR this line is for
# +line_type+::     +integer+ -- One of Cached::TextLine::LineTypes
# +line_number+::   +integer+ -- Line number
# +text_type_ord+:: +integer+ -- For addtxt lines, this is the first
#                                byte of the line which is used to
#                                distinguish it as a signature line,
#                                etc.
# +text+::          +string+  -- The text of the line
#
class CreateCachedTextLines < ActiveRecord::Migration
  def self.up
    create_table :cached_text_lines do |t|
      t.integer :pmr_id,        :null => false
      t.integer :line_type,     :null => false
      t.integer :line_number,   :null => false
      t.integer :text_type_ord, :null => false
      t.string  :text,          :null => false, :limit => 72
      t.timestamps 
    end
    execute("ALTER TABLE cached_text_lines ADD CONSTRAINT unique_text_lines " +
            "UNIQUE (pmr_id, line_type, line_number)")
  end

  def self.down
    drop_table :cached_text_lines
  end
end
