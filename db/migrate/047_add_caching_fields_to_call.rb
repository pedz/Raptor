# -*- coding: utf-8 -*-
#
# This migration adds a batched of fields that were computed during
# display time but are now computed during fetch time and stored in
# the database.
#
class AddCachingFieldsToCall < ActiveRecord::Migration
  def self.up
    add_column :cached_calls, :owner_css,           :string
    add_column :cached_calls, :owner_message,       :string
    add_column :cached_calls, :owner_editable,      :boolean

    add_column :cached_calls, :resolver_css,        :string
    add_column :cached_calls, :resolver_message,    :string
    add_column :cached_calls, :resolver_editable,   :boolean

    add_column :cached_calls, :next_queue_css,      :string
    add_column :cached_calls, :next_queue_message,  :string
    add_column :cached_calls, :next_queue_editable, :boolean
  end

  def self.down
    remove_column :cached_calls, :owner_css
    remove_column :cached_calls, :owner_message
    remove_column :cached_calls, :owner_editable

    remove_column :cached_calls, :resolver_css
    remove_column :cached_calls, :resolver_message
    remove_column :cached_calls, :resolver_editable

    remove_column :cached_calls, :next_queue_css
    remove_column :cached_calls, :next_queue_message
    remove_column :cached_calls, :next_queue_editable
  end
end
