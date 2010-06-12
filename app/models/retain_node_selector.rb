# -*- coding: utf-8 -*-

# = Retain Node Selector
# The retuser has two fields, hardware_node_id and software_node_id
# which "point" to a retain node selector.  A retain node selector in
# turn points to a retain node.  The reason for the extra indirection
# is 99% of the retuser entries will point to the default software and
# hardware node selectors which in turn will point to probably the
# primary port of BDC and SF2 for the software and hardware nodes
# respectively.
#
# If these nodes go down, the admin for Raptor can change the default
# to point to another node and most users will be up and running.  The
# only users that might still need to alter their settings would be
# those using APPTEST (which know what they are doing presumably) and
# perhaps the EMNET teams since they might be using the nodes in
# England rather than the U.S. nodes.
#
# But they too could be quickly flipped if needed.
#
# ==Fields
#
# <em>id - integer</em>::
#   The key field for the table.
# <em>description - string</em>::
#   A nice description since this is what the normal users are going
#   to see.
# <em>retain_node_id - integer</em>::
#   Foreign key to the retain_nodes table.
#
class RetainNodeSelector < ActiveRecord::Base
  belongs_to :retain_node
end
