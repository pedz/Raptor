module Retain
  class PsarUpdate

    attr_accessor :psar_service_code, :psar_action_code, :psar_cause
    attr_accessor :psar_impact, :psar_solution, :psar_actual_time
    attr_accessor :psar_chargeable_time, :hours, :minutes

    def initialize(service, action, cause, impact, solution, hours, minutes)
      RAILS_DEFAULT_LOGGER.debug("HERE HERE")
      @psar_service_code = service
      @psar_action_code = action
      @psar_cause = cause
      @psar_impact = impact
      @psar_solution = solution
      @hours = hours
      @minutes = minutes
    end
  end
end
