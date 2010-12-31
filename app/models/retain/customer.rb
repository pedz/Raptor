# -*- coding: utf-8 -*-

module Retain
  class Customer < Base
    set_fetch_sdi Pmcp

    def initialize(params, options = {})
      super(params, options)
    end

    # Returns true if the customer is a valid customer.  For now, we
    # just return true.  We might do a fetch from retain if we find we
    # need to.
    def self.valid?(options)
      new_options = {
        :country => options[:country],
        :customer_number => options[:customer_number],
        :group_request => [[ :company_name ]]
      }
      customer = new(new_options)
      begin
        company_name = customer.company_name
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
