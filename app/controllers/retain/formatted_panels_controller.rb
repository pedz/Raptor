# -*- coding: utf-8 -*-

module Retain
  class FormattedPanelsController < RetainController
    def show
      options = { }
      options[:center] = signon_user.default_center.center
      options[:format_panel_number] = params[:id]
      @formatted_panel = Retain::FormattedPanel.new(@params, options)
    end
  end
end
