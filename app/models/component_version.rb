# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class ComponentVersion < ActiveRecord::Base
  set_table_name "c_component_version"
  belongs_to :component, :foreign_key => :component_id, :primary_key => :component_id
end
