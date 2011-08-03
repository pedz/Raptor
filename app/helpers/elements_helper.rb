# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module ElementsHelper
  def widget_list
    Widget.all.select { |widget| @view.match_pattern.match(Regexp.new(widget.match_pattern)) }
  end
end
