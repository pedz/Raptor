module Retain
  class IoscController < RetainController
    def index
      pmis = Retain::Pmis.new(retain_user_connection_parameters, { })
      fields = Retain::Fields.new
      pmis.sendit(fields)
      logger.debug("Hi!! #{pmis.rc}")
      logger.debug("de32 lenth is #{fields.de32s.length}")
      fields.de32s.each do |f|
        logger.debug("#{f.isoc_country_name} #{f.country} #{f.daylight_savings_start_date} #{f.daylight_savings_stop_date}")
      end
      logger.debug("Bye")
    end
  end
end
