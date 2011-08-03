# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # === Retain Customer Moel
  #
  # A model representing Retain customers.  See Cached::Customers for
  # a list of attributes that are cached and Combined::Customer for
  # how the particulars on how the Retain model and the Cached model
  # are joined in this particular instance.
  class Customer < Retain::Base
    ##
    # :attr: fetch_sdi
    # Set to Retain::Pmcp
    set_fetch_sdi Pmcp

    ##
    # :attr: fetch_sdi
    # Set to Retain::Ssbr
    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Returns true if the customer is a valid customer.  For now, we
    # just return true.  We might do a fetch from retain if we find we
    # need to.
    def self.valid?(retain_user_connection_parameters, options)
      new_options = {
        :country => options[:country],
        :customer_number => options[:customer_number],
        :group_request => [[ :company_name ]]
      }
      customer = new(retain_user_connection_parameters, new_options)
      begin
        company_name = customer.company_name
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
