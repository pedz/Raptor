class CreateNestings < ActiveRecord::Migration
  def self.up
    execute "
      CREATE VIEW nestings AS
        WITH RECURSIVE temp AS (
          SELECT * FROM containers
          UNION ALL
            SELECT
              temp.container_id,
              temp.container_type,
              containers.element_name_id,
              containers.element_name_type,
              temp.level + 1 as level
            FROM
              temp,
              containers
            WHERE
              temp.element_name_id   = containers.container_id AND
              temp.element_name_type = containers.container_type AND
              temp.level < 20	 -- Here just to prevent an infinite loop
          )
        SELECT
          *
        FROM
          temp
        ORDER BY
          container_type,
          container_id,
          element_name_type,
          element_name_id
      ;"
  end

  def self.down
    execute "DROP VIEW nestings;"
  end
end
