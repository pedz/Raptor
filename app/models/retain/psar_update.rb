module Retain
  class PsarUpdate

    attr_accessor :psar_service_code, :psar_action_code, :psar_cause
    attr_accessor :psar_impact, :psar_solution, :psar_actual_time
    attr_accessor :psar_chargeable_time, :hours, :minutes
    attr_accessor :stop_year, :stop_month, :stop_day, :stop_hour, :stop_minute

    def initialize(service, action, cause, impact, solution, hours, minutes)
      @psar_service_code = service
      @psar_action_code  = action
      @psar_cause        = cause
      @psar_impact       = impact
      @psar_solution     = solution
      @hours             = hours
      @minutes           = minutes
      t = Time.now
      @stop_year   = t.year
      @stop_month  = t.month
      @stop_day    = t.day
      @stop_hour   = t.hour
      @stop_minute = t.min
    end
  end
end
