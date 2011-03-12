# -*- coding: utf-8 -*-

module Retain
  class Customer < Base
    set_fetch_sdi Pmcp

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
