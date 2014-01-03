# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Retain
  # == Retain Call Update model
  #
  # Not a normal retain model.  This is a model used to update a call.
  # It is in the models directory because it is used with views to
  # create the update forms used in the combined qs and combined calls
  # pages.  (ok... but why is it called "Retain::CallUpdate and not
  # just CallUpdate?)
  class CallUpdate

    attr_reader   :call
    attr_accessor :update_pmr, :update_type, :do_ct, :newtxt, :add_time
    attr_accessor :new_queue, :new_priority, :service_given
    attr_accessor :psar_update, :do_ca
    attr_accessor :hot, :business_justification
    
    def initialize(call)
      # Rails.logger.debug("call_update initialize")
      @call = call
      @update_type = "addtxt"
      @update_pmr = true
      @do_ct = true
      @do_ca = false
      @newtxt = "Action Taken:\n\nAction Plan:\n"
      @add_time = true
      @psar_update = PsarUpdate.new(75, 57, 50, call.priority, 9, 0, 30)
      @new_queue = call.queue.to_param
      @new_priority = call.priority
      @service_given = 99
      @pmr = call.pmr
      @hot = @pmr.hot
      @business_justification = @pmr.business_justification
    end

    def last_sg
      sg_lines = @pmr.service_given_lines
      if sg_lines.empty?
        "NG"
      else
        sg_lines.last.service_given
      end
    end

    def to_id
      @_to_id ||= @call.to_id
    end

    def id
      @_id ||= @call.id
    end
    
    def to_param
      @_to_param ||= @call.to_param
    end
  end
end
