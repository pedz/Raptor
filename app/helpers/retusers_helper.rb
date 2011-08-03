# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module RetusersHelper
  def node_selector_list(test_mode, node_type)
    RetainNodeSelector.
      find(:all,
           :joins => [ :retain_node ],
           :conditions => {
             "retain_nodes.apptest" => test_mode,
             "retain_nodes.node_type" => node_type
           }).
      collect { |n|
      [ n.description, n.id ]
    }
  end
end
