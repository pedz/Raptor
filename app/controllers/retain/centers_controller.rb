module Retain
  class CentersController < RetainController
    def index
      group_request = [ :center,
                        :software_center_mnemonic,
                        :center_daylight_time_flag,
                        :delay_to_time,
                        :minutes_from_gmt                        
                      ]
      options = {
        :group_request => group_request
      }
      @centers = Retain::Center.new(options).de32s
    end
    
    def show
      group_request = [ :software_center_mnemonic,
                        :center_daylight_time_flag,
                        :delay_to_time,
                        :minutes_from_gmt                        
                      ]
      options = {
        :center => params[:id],
        :group_request => group_request
      }
      @center = Retain::Center.new(options)
    end
  end
end
