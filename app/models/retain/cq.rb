# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # Class created just so we can check if a queue is valid or not.
  # This class now has no real point since queue now uses PMCS but it
  # is still used -- go figure.
  class Cq < Retain::Base
    ##
    # :attr: fetch_sdi
    # Set to Retain::Pmcs
    set_fetch_sdi Pmcs

    # retain_user_connection_parameters and options are passed up to
    # Retain::Base.initialize
    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Returns true if the queue is valid.
    def self.valid?(retain_user_connection_parameters, options)
      # short circuit asking if queue_name or center is blank
      return false if options[:queue_name].blank? || options[:center].blank?
      cq = Retain::Cq.new(retain_user_connection_parameters, options)
      begin
        hit_count = cq.hit_count # get hit_count to see if the queue is valid
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
