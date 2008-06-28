#
# This class is a "model" in the sense that it holds the data elements
# but it is not backed by a database table.  It is just a record
# (could be a struct) for fields used in the call update partial.
#
module Retain
  class CallUpdate

    attr_accessor :update_pmr, :update_type, :do_ct, :newtxt, :add_time
    attr_accessor :service_code, :action_code, :cause, :solution, :impact
    attr_accessor :hours, :minutes

    def initialize(call)
      RAILS_DEFAULT_LOGGER.debug("call_update initialize")
      @call = call
      @update_type = "addtxt"
      @update_pmr = :true
      @do_ct = :true
      @newtxt = "Action Taken:\n\nAction Plan:\n"
      @add_time = :true
      @service_code = 75
      @action_code = 57
      @cause = 50
      @solution = 9
      @impact = 3
      @hours = 0
      @minutes = 30
    end

    def to_param
      @call.to_param
    end
  end
end
