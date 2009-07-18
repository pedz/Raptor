class AddReturnValueAndReasonToRetUsers < ActiveRecord::Migration
  def self.up
    add_column :retusers, :return_value, :integer
    add_column :retusers, :reason,       :integer
  end

  def self.down
    remove_column :retusers, :reason
    remove_column :retusers, :return_value
  end
end
