class AddServiceRequestToCachedPmrs < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :service_request, :string
  end

  def self.down
    remove_column :cached_pmrs, :service_request
  end
end
