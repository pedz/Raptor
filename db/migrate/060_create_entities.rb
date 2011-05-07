class CreateEntities < ActiveRecord::Migration
  def self.up
    execute "CREATE VIEW entities AS
               SELECT
                 name AS name,
                 id AS item_id,
                 type AS item_type
               FROM names
             UNION ALL
               SELECT
                 ldap_id AS name,
                 id AS item_id,
                 'User' AS item_type
               FROM users
             UNION ALL
               SELECT
                 retid AS name,
                 id AS item_id,
                 'Retuser' AS item_type
               FROM retusers
             ;"
  end

  def self.down
    execute "DROP VIEW entities"
  end
end
