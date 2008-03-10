class CreateFeedbackNotes < ActiveRecord::Migration
  def self.up
    create_table :feedback_notes do |t|
      t.integer :feedback_id
      t.text    :note
      t.timestamps 
    end
    execute "ALTER TABLE feedback_notes ADD CONSTRAINT fk_feedback_notes_feedback_id
             FOREIGN KEY (feedback_id) REFERENCES feedbacks(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :feedback_notes
  end
end
