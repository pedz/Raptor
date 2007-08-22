class CreateRetainPmrs < ActiveRecord::Migration
  def self.up
    create_table :retain_pmrs do |t|
      t.string :problem
      t.string :branch
      t.string :country

      t.timestamps 
    end
  end

  def self.down
    drop_table :retain_pmrs
  end
end
