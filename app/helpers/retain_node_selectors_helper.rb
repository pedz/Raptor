# -*- coding: utf-8 -*-
module RetainNodeSelectorsHelper
  def retain_node_list
    RetainNode.all.collect { |n|
      [ "#{n.description} (#{n.node_type})", n.id ]
    }
  end
end
