# -*- coding: utf-8 -*-

class CreateTeamQueues < ActiveRecord::Migration
  def self.up
    create_table :team_queues do |t|
      t.integer :team_id
      t.integer :cached_queue_id
      t.timestamps
    end
    execute "ALTER TABLE team_queues ADD CONSTRAINT uq_team_queues_queue_owner
             UNIQUE (cached_queue_id)"
    execute "ALTER TABLE team_queues ADD CONSTRAINT fk_team_queues_cached_queue_id
             FOREIGN KEY (cached_queue_id) REFERENCES cached_queues(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE team_queues ADD CONSTRAINT fk_team_queues_team_id
             FOREIGN KEY (team_id) REFERENCES teams(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :team_queues
  end
end
