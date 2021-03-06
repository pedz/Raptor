# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class CentersController < RetainController
    def index
      group_request = [
                       :center,
                       :software_center_mnemonic,
                       :center_daylight_time_flag,
                       :delay_to_time,
                       :minutes_from_gmt,
                       :absorbed_queue_list
                      ]
      options = {
        :group_request => [ group_request ]
      }
      @centers = Retain::Center.new(retain_user_connection_parameters, options).de32s
    end
    
    def show
      @center = Combined::Center.from_param!(params[:id], signon_user)
    end
  end
end
