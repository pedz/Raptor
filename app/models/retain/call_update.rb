#
# This class is a "model" in the sense that it holds the data elements
# but it is not backed by a database table.  It is just a record
# (could be a struct) for fields used in the call update partial.
#
module Retain
  class CallUpdate

    attr_reader   :call
    attr_accessor :update_pmr, :update_type, :do_ct, :newtxt, :add_time
    attr_accessor :new_queue, :new_priority
    attr_accessor :psar_update
    
    def initialize(call)
      RAILS_DEFAULT_LOGGER.debug("call_update initialize")
      @call = call
      @update_type = "addtxt"
      @update_pmr = :true
      @do_ct = :true
      @newtxt = "Action Taken:\n\nAction Plan:\n"
      @add_time = :true
      @psar_update = PsarUpdate.new(75, 57, 50, call.priority, 9, 0, 30)
      @new_queue = call.queue.to_param
      @new_priority = call.priority
    end

    def to_id
      @call.to_id
    end

    def to_param
      @call.to_param
    end
  end
end
