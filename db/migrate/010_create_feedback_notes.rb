class CreateFeedbackNotes < ActiveRecord::Migration
  def self.up
    create_table :feedback_notes do |t|
      t.integer :feedback_id
      t.text    :note

      t.timestamps 
    end
  end

  def self.down
    drop_table :feedback_notes
  end
end
