# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class UserEntityCounts < ActiveRecord::Migration
  def self.up
    execute "CREATE VIEW user_entity_counts AS
               SELECT
                 user_id,
                 name,
                 t1.match_pattern,
                 t1.argument_type,
                 t1.real_type,
                 COALESCE ( t2.count, t1.count ) AS count,
                 COALESCE ( t2.updated_at, t1.updated_at ) AS updated_at
               FROM
               (
                 SELECT
                   u.id AS user_id,
                   e.name,
                   e.match_pattern,
                   e.argument_type,
                   e.real_type,
                   0 AS count,
                   u.updated_at
                 FROM
                   users u,
                   entities e
               ) AS t1
               LEFT OUTER JOIN
               (
                 SELECT
                   c.user_id,
                   c.name,
                   c.count,
                   c.updated_at
                 FROM
                   use_counters c
               ) AS t2
               USING ( user_id, name );"
  end

  def self.down
    execute "DROP VIEW user_entity_counts"
  end
end
