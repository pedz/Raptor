# -*- coding: utf-8 -*-
module ElementsHelper
  def widget_list
    Widget.all.select { |widget| @view.match_pattern.match(Regexp.new(widget.match_pattern)) }
  end
end
