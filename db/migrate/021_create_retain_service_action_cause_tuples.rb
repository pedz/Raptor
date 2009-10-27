# -*- coding: utf-8 -*-

class CreateRetainServiceActionCauseTuples < ActiveRecord::Migration
  def self.up
    create_table :retain_service_action_cause_tuples do |t|
      t.integer :psar_service_code
      t.integer :psar_action_code
      t.integer :psar_cause
      t.boolean :apar_required
      t.string  :description
      t.timestamps
    end
    execute "ALTER TABLE retain_service_action_cause_tuples
             ADD CONSTRAINT uq_retain_service_action_cause_tuples
             UNIQUE (psar_service_code, psar_action_code, psar_cause)"
  end

  def self.down
    drop_table :retain_service_action_cause_tuples
  end
end
