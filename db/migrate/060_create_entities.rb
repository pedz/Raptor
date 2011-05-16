class CreateEntities < ActiveRecord::Migration
  def self.up
    execute "CREATE VIEW entities AS
        SELECT
          name,
          item_id,
          item_type,
          name_type_id,
          real_type,
          base_type,
          table_name,
          container,
          containable,
          argument_type_id,
          argument_type,
          \"default\",
          position
        FROM
        (
            (
                SELECT
                  name AS name,
                  type AS real_type,
                  id AS item_id
                FROM
                  names
                UNION ALL
                  SELECT
                    ldap_id AS name,
                    'User' AS real_type,
                    id AS item_id
                  FROM
                    users
                UNION ALL
                  SELECT
                    retid AS name,
                    'Retuser' AS item_type,
                    id AS item_id
                  FROM
                    retusers
            ) AS t1
            LEFT OUTER JOIN
            (
              SELECT
                id AS name_type_id,
                name AS real_type,
                base_type AS item_type,
                base_type,
                table_name,
                argument_type_id,
                container,
                containable
              FROM
                name_types
            ) AS t2
            USING ( real_type )
        ) AS t3
        LEFT OUTER JOIN
        (
          SELECT
            id as argument_type_id,
            name AS argument_type,
            \"default\",
            position
          FROM
            argument_types
        ) AS t4
        USING ( argument_type_id )
        ;
        "
  end

  def self.down
    execute "DROP VIEW entities"
  end
end
