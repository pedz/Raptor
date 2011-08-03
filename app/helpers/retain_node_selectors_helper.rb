# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module RetainNodeSelectorsHelper
  def retain_node_list
    RetainNode.all.collect { |n|
      [ "#{n.description} (#{n.node_type})", n.id ]
    }
  end
end
