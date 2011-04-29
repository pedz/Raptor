class CreateContainers < ActiveRecord::Migration
  def self.up
    execute "
      CREATE VIEW containers AS
        SELECT
          r.container_name_id AS container_id,
          n.type AS container_type,
          r.element_name_id AS element_name_id,
          r.element_name_type AS element_name_type,
          1 as level
        FROM
          relationships r,
          names n
        WHERE
          r.container_name_id = n.id
      UNION ALL
        SELECT
          u.id AS container_id,
          'User' AS container_type,
          cqi.queue_id AS element_name_id,
          'Cached::Queue' AS element_name_type,
          1 AS level
        FROM users u, retusers r, cached_registrations cr, cached_queue_infos cqi
        WHERE
          u.id = r.user_id AND
          r.retid = cr.signon AND
          cr.id = cqi.owner_id
      ;"
  end

  def self.down
    execute "DROP VIEW containers;"
  end
end
