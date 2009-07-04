module Retain
  class CentersController < RetainController
    def index
      group_request = [
                       :center,
                       :software_center_mnemonic,
                       :center_daylight_time_flag,
                       :delay_to_time,
                       :minutes_from_gmt                        
                      ]
      options = {
        :group_request => [ group_request ]
      }
      @centers = Retain::Center.new(options).de32s
    end
    
    def show
      @center = Combined::Center.from_param(params[:id])
    end
  end
end
