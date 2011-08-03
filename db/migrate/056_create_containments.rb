# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateContainments < ActiveRecord::Migration
  def self.up
    execute "
      CREATE VIEW containments AS
        SELECT
          r.container_name_id AS container_id,
          'Name' AS container_type,
          at.association_type AS association_type,
          r.item_id AS item_id,
          r.item_type AS item_type,
          1 as level,
          r.updated_at AS updated_at
        FROM
          relationships r,
          relationship_types rt,
          association_types at
        WHERE
          r.relationship_type_id = rt.id AND
          rt.association_type_id = at.id
      UNION ALL
        SELECT
          r.user_id AS container_id,
          'User' AS container_type,
          'owner' AS association_type,
          cqi.queue_id AS item_id,
          'Cached::Queue' AS item_type,
          1 AS level,
          cqi.updated_at AS updated_at
        FROM
          retusers r,
          cached_registrations cr,
          cached_queue_infos cqi
        WHERE
          r.retid = cr.signon AND
          cr.id = cqi.owner_id
      UNION ALL
        SELECT
          f.retuser_id AS container_id,
          'Retuser' AS container_type,
          'favorite' AS association_type,
          f.queue_id AS item_id,
          'Cached::Queue' AS item_type,
          1 AS level,
          f.updated_at AS updated_at
        FROM
          favorite_queues f
      ;"
  end

  def self.down
    execute "DROP VIEW containments;"
  end
end
