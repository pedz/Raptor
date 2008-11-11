class CreateRetainServiceGivenCodes < ActiveRecord::Migration
  def self.up
    create_table :retain_service_given_codes do |t|
      t.integer :service_given
      t.string :description
      t.timestamps
    end
    execute "ALTER TABLE retain_service_given_codes
             ADD CONSTRAINT uq_retain_service_given_codes
             UNIQUE (service_given)"
  end

  def self.down
    drop_table :retain_service_given_codes
  end
end
