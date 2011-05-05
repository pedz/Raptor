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
              containers.item_id,
              containers.item_type,
              temp.level + 1 as level
            FROM
              temp,
              containers
            WHERE
              temp.item_id   = containers.container_id AND
              temp.item_type = containers.container_type AND
              temp.level < 20	 -- Here just to prevent an infinite loop
          )
        SELECT
          *
        FROM
          temp
        ORDER BY
          container_type,
          container_id,
          item_type,
          item_id
      ;"
  end

  def self.down
    execute "DROP VIEW nestings;"
  end
end
