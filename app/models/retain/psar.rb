module Retain
  class Psar < Base
    set_fetch_sdi Psrr

    def self.range(start_date, stop_date)
      temp = Retain::Psar.new(:psar_start_date => start_date.strftime("%Y%m%d"),
                              :psar_end_date => stop_date.strftime("%Y%m%d"))
      temp.de32s.map do |fields|
        Psar.new :fields => fields
      end
    end

    def initialize(options = {})
      super(options)
    end
    
    def to_s
      "BlahBlahBlah"
    end
  end
end
