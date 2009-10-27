# -*- coding: utf-8 -*-

module Cached
  class Psar < Base
    set_table_name "cached_psars"
    belongs_to :pmr,          :class_name => "Cached::Pmr"
    belongs_to :center,       :class_name => "Cached::Center"
    belongs_to :queue,        :class_name => "Cached::Queue"
    belongs_to :registration, :class_name => "Cached::Registration"
    # There is also a belongs_to for APARs but it is not used in our
    # area so it is not hooked up yet.
    named_scope :today, lambda {
      {
        :conditions => { :psar_system_date => Time.now.strftime('%y%m%d') }
      }
    }
    named_scope :stop_time_range, lambda { |range|
      {
        :conditions => (%Q{("cached_psars"."stop_time_moc" + "cached_psars"."minutes_from_gmt")} +
                        "BETWEEN #{range.first} AND #{range.last}")
      }
    }

    def stop_time_date
      Time.moc(stop_time_moc + minutes_from_gmt)
    end
    once :stop_time_date
    
    def stop_date
      std = stop_time_date
      Time.gm(std.year, std.month, std.day)
    end
    once :stop_date

    def before_destroy
      options = { :operand => 'DEL ', :psar_file_and_symbol => psar_file_and_symbol }
      psru = Retain::Psru.new(options)
      begin
        psru.sendit(Retain::Fields.new)
      rescue Retain::SdiReaderError => err
        # If the guy is already gone then thats o.k.
        # logger.debug("before_destroy: SR=#{err.sr} EX=#{err.ex}")
        return (err.sr == 176 && err.ex == 510)
      end
      return true
    end
  end
end
