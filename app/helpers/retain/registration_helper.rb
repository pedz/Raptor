# -*- coding: utf-8 -*-

module Retain
  module RegistrationHelper
    def center_link(center)
      if center.center == "000"
        "None"
      else
        link_to center.center, combined_center_path(center)
      end
    end
  end
end
