# -*- coding: utf-8 -*-

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
