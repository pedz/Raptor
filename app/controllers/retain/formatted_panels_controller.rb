# -*- coding: utf-8 -*-

module Retain
  class FormattedPanelsController < RetainController
    def show
      options = { }
      options[:center] = signon_user.default_center.center
      options[:format_panel_number] = params[:id]
      @formatted_panel = Retain::FormattedPanel.new(retain_user_connection_parameters, options)
    end
  end
end
