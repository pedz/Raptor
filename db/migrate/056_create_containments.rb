# -*- coding: utf-8 -*-
class CreateContainments < ActiveRecord::Migration
  def self.up
    execute "
      CREATE VIEW containments AS
        SELECT
          r.container_name_id AS container_id,
          'Name' AS container_type,
          r.item_id AS item_id,
          r.item_type AS item_type,
          1 as level
        FROM
          relationships r
      UNION ALL
        SELECT
          u.id AS container_id,
          'User' AS container_type,
          cqi.queue_id AS item_id,
          'Cached::Queue' AS item_type,
          1 AS level
        FROM users u, retusers r, cached_registrations cr, cached_queue_infos cqi
        WHERE
          u.id = r.user_id AND
          r.retid = cr.signon AND
          cr.id = cqi.owner_id
      UNION ALL
        SELECT
          f.retuser_id AS container_id,
          'Retuser' AS container_type,
          f.queue_id AS item_id,
          'Cached::Queue' AS item_type,
          1 AS level
        FROM favorite_queues f
      ;"
  end

  def self.down
    execute "DROP VIEW containments;"
  end
end
