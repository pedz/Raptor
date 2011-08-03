# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# === Retain Node Selector
#
# The retuser has two fields, hardware_node_id and software_node_id
# which specify a RetainNodeSelector.  A retain node selector in turn
# points to a RetainNode.  The reason for the extra indirection is 99%
# of the retuser entries will point to the default software and
# hardware node selectors which in turn will point to probably the
# primary port of BDC and SF2 for the software and hardware nodes
# respectively.
#
# If these nodes go down, the admin for Raptor can change the default
# to point to another node and most users will be up and running.  The
# only users that might still need to alter their settings would be
# those using APPTEST (which know what they are doing presumably) and
# perhaps the EMNET teams since they might be using the nodes in
# England rather than the U.S. nodes.  But they too could be quickly
# flipped if needed.
#
class RetainNodeSelector < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.

  ##
  # :attr: description
  # A text description of this selector such as "Default software node
  # for Austin Teams"

  ##
  # :attr: retain_node_id
  # The id from the retain_nodes table.

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

  ##
  # :attr: retain_node
  # A belongs_to association to the Retain Node that this select is
  # currently using.
  belongs_to :retain_node
end
