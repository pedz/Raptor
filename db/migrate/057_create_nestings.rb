# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateNestings < ActiveRecord::Migration
  def self.up
    execute "
      CREATE VIEW nestings AS
        WITH RECURSIVE temp AS (
          SELECT
            *
          FROM 
            containments
          UNION ALL
            SELECT
              temp.container_id,
              temp.container_type,
              containments.association_type,
              containments.item_id,
              containments.item_type,
              temp.level + 1 AS level,
              containments.updated_at
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
      UNION ALL
        SELECT
          q.id AS container_id,
          'Cached::Queue' AS container_type,
          'self' AS association_type,
          q.id AS item_id,
          'Cached::Queue' AS item_type,
          1 AS level,
          q.updated_at AS updated_at
        FROM
          cached_queues q
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
