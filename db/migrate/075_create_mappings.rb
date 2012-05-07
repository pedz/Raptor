class CreateMappings < ActiveRecord::Migration
  def self.up
    create_table :mappings do |t|
      t.integer :subject_id, :null => false
      t.integer :source_id,  :null => false
      t.string :sql, :null => false
      t.timestamps
    end
    execute "CREATE FUNCTION check_subject_type(index integer)
             RETURNS boolean AS
             $$
             SELECT 'Subject' = ( SELECT \"type\" FROM \"names\" WHERE \"id\" = $1)
             $$ LANGUAGE 'sql';
             "
    execute "CREATE FUNCTION check_source_base_type(index integer)
             RETURNS boolean AS
             $$
             SELECT 'Name' != ( SELECT \"base_type\" FROM \"name_types\" WHERE \"id\" = $1)
             $$ LANGUAGE 'sql';
             "
    execute "ALTER TABLE mappings ADD CONSTRAINT uq_mappings_tuple
             UNIQUE (subject_id, source_id)"
    execute "ALTER TABLE mappings ADD CONSTRAINT fk_mappings_subject_id
             FOREIGN KEY (subject_id) REFERENCES names(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE mappings ADD CONSTRAINT fk_mappings_source_id
             FOREIGN KEY (source_id) REFERENCES name_types(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE mappings ADD CONSTRAINT ck_mappings_subject_id
             CHECK (check_subject_type(subject_id));"
    execute "ALTER TABLE mappings ADD CONSTRAINT ck_mappings_source_id
             CHECK (check_source_base_type(source_id));"
  end

  def self.down
    drop_table :mappings
    execute "DROP FUNCTION check_subject_type(index integer)"
    execute "DROP FUNCTION check_source_base_type(index integer)"
  end
end
