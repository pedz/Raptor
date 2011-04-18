class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer :container_type_id
      t.integer :association_type_id
      t.integer :element_type_id
      t.timestamps
    end
    execute "ALTER TABLE relationships ADD CONSTRAINT uq_relationship_tuple UNIQUE
                 (container_type_id, association_type_id, element_type_id)"
    execute "ALTER TABLE relationships ADD CONSTRAINT fk_relationship_container_type
             FOREIGN KEY (container_type_id) REFERENCES name_types(id)
             ON DELETE NO ACTION"
    execute "ALTER TABLE relationships ADD CONSTRAINT fk_relationship_association_type
             FOREIGN KEY (association_type_id) REFERENCES association_types(id)
             ON DELETE NO ACTION"
    execute "ALTER TABLE relationships ADD CONSTRAINT fk_relationship_element_type
             FOREIGN KEY (element_type_id) REFERENCES name_types(id)
             ON DELETE NO ACTION"
  end

  def self.down
    drop_table :relationships
  end
end
