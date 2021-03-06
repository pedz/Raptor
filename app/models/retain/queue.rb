# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # === Retain Queue Model
  #
  # A model representing Retain queues.  See Cached::Queues for a list
  # of attributes that are cached and Combined::Queue for how the
  # particulars on how the Retain model and the Cached model are
  # joined in this particular instance.
  class Queue < Retain::Base
    ##
    # :attr: fetch_sdi
    # Set to Retain::Pmcs
    set_fetch_sdi Pmcs

    # retain_user_connection_parameters and options are passed up to
    # Retain::Base.initialize
    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Returns true if the queue is a valid queue.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(retain_user_connection_parameters, options)
      # short circuit asking if queue_name or center is blank
      return false if options[:queue_name].blank? || options[:center].blank?
      cq = Retain::Cq.new(retain_user_connection_parameters, options)
      begin
        hit_count = cq.hit_count # get hit_count to see if the queue is valid
        return true

        # The assumption here is that the queue was found but it is
        # messed up in Retain.  That happens some times.
      rescue Retain::SdiDidNotReadField
        return true

        # The assumption is that the SDI error is because the queue
        # was not found.  We could check for that condition.
      rescue Retain::SdiReaderError => e
        return false
      end
    end
    
    # Returns queue_name,center optionally ,H ... thats just weird.
    def to_s
      ret = queue_name.strip + ',' + center
      if h_or_s? && h_or_s != 'S' && h_or_s != 's'
        ret << h_or_s
      end
      ret
    end
    

    # Returns the list of calls from the de32 field as Retain::Call
    # objects.
    def calls
      return [] if hit_count == 0
      local_h_or_s = h_or_s
      de32s.map do |fields|
        temp = fields.call_search_result
        options = { 
          :center => decode_center(temp[0 ... 2]),
          :queue_name => temp[2 ... 8].retain_to_user.strip,
          :h_or_s => local_h_or_s,
          :ppg => "%x" % (temp[10].ord * 256 + temp[11].ord),
          :p_s_b => fields.p_s_b,
          :system_down => fields.system_down,
          :call_search_result => temp
        }
        # logger.debug("RTN: raw iris is #{temp[0 ... 12]}")
        # logger.debug("RTN: make a call options: #{options.inspect}")
        Call.new(retain_user_connection_parameters, options)
      end
    end

    private

    # Decodes the center field that is returned from the Pmcs call.
    def decode_center(v)
      s = v.ret2ushort
      i1 = s / 100;
      i2 = s % 100;
      i3 = i1 - 10;

      ## if it is less than 26, than it's an alphanumeric
      ## center like 13L
      return ("%02d%c" % [ i2, (?A.ord + i3)]) if i3 >= 0 && i3 <= 25

      ## Otherwise it is pure numeric
      return ("%03d" % s)
    end
  end
end
