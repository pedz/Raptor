class CreateRelationshipTypes < ActiveRecord::Migration
  def self.up
    create_table :relationship_types do |t|
      t.integer :container_type_id, :null => false
      t.integer :association_type_id, :null => false
      t.integer :element_type_id, :null => false
      t.timestamps
    end
    execute "ALTER TABLE relationship_types ADD CONSTRAINT uq_relationship_type_tuple UNIQUE
                 (container_type_id, association_type_id, element_type_id)"
    execute "ALTER TABLE relationship_types ADD CONSTRAINT fk_relationship_type_container_type
             FOREIGN KEY (container_type_id) REFERENCES name_types(id)
             ON DELETE NO ACTION"
    execute "ALTER TABLE relationship_types ADD CONSTRAINT fk_relationship_type_association_type
             FOREIGN KEY (association_type_id) REFERENCES association_types(id)
             ON DELETE NO ACTION"
    execute "ALTER TABLE relationship_types ADD CONSTRAINT fk_relationship_type_element_type
             FOREIGN KEY (element_type_id) REFERENCES name_types(id)
             ON DELETE NO ACTION"
  end

  def self.down
    drop_table :relationship_types
  end
end
