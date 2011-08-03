# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateEntities < ActiveRecord::Migration
  def self.up
    execute "CREATE VIEW entities AS
        SELECT
          name,
          item_id,
          item_type,
          match_pattern,
          name_type_id,
          real_type,
          base_type,
          table_name,
          container,
          containable,
          argument_type_id,
          argument_type,
          \"default\",
          position,
          updated_at
        FROM
        (
            (
                SELECT
                  name AS name,
                  type AS real_type,
                  id AS item_id,
                  match_pattern AS match_pattern,
                  updated_at AS updated_at
                FROM
                  names
                UNION ALL
                  SELECT
                    ldap_id AS name,
                    'User' AS real_type,
                    id AS item_id,
                    'people' AS match_pattern,
                    updated_at AS updated_at
                  FROM
                    users
                UNION ALL
                  SELECT
                    retid AS name,
                    'Retuser' AS real_type,
                    id AS item_id,
                    'people' AS match_pattern,
                    updated_at AS updated_at
                  FROM
                    retusers
                UNION ALL
                  SELECT
                    q.queue_name || ',' || q.h_or_s || ',' || c.center AS name,
                    'Cached::Queue' AS real_type,
                    q.id AS item_id,
                    'queues' AS match_pattern,
                    q.updated_at AS updated_at
                  FROM
                    cached_queues q,
                    cached_centers c
                  WHERE
                    q.center_id = c.id
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
