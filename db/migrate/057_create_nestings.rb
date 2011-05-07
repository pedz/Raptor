class CreateNestings < ActiveRecord::Migration
  def self.up
    execute "
      CREATE VIEW nestings AS
        WITH RECURSIVE temp AS (
          SELECT * FROM containments
          UNION ALL
            SELECT
              temp.container_id,
              temp.container_type,
              containments.item_id,
              containments.item_type,
              temp.level + 1 as level
            FROM
              temp,
              containments
            WHERE
              temp.item_id   = containments.container_id AND
              temp.item_type = containments.container_type AND
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
