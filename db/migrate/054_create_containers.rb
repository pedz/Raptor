class CreateContainers < ActiveRecord::Migration
  def self.up
    create_table :containers do |t|
      t.integer :container_name_id
      t.integer :relationship_id
      # Polymorphic belongs_to
      t.integer :element_name_id
      t.string  :element_name_type
      t.integer :owner_id
      t.timestamps
    end
    execute "ALTER TABLE containers ADD CONSTRAINT uq_container_tuple UNIQUE
             (container_name_id, element_name_id, element_name_type)"
    execute "ALTER TABLE containers ADD CONSTRAINT fk_containers_container_name
             FOREIGN KEY (container_name_id) REFERENCES names(id)
             ON DELETE NO ACTION"
    execute "ALTER TABLE containers ADD CONSTRAINT fk_containers_relationship
             FOREIGN KEY (relationship_id) REFERENCES relationships(id)
             ON DELETE NO ACTION"
  end

  def self.down
    drop_table :containers
  end
end
