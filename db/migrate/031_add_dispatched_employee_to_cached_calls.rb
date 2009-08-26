class AddDispatchedEmployeeToCachedCalls < ActiveRecord::Migration
  def self.up
    add_column :cached_calls, :dispatched_employee, :string
    add_column :cached_calls, :call_control_flag_1, :integer
  end

  def self.down
    remove_column :cached_calls, :call_control_flag_1
    remove_column :cached_calls, :dispatched_employee
  end
end
