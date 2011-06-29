# -*- coding: utf-8 -*-

module Retain
  # A model representing Retain customers.  See Cached::Customers for
  # a list of attributes that are cached.  Uses Retain::Pmcp to fetch
  # data from Retain so see it for what can be retrieved from Retain
  # using this model.  Also see Combined::Customer for how the
  # particulars on how the Retain model and the Cached model are
  # joined in this particular instance.
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
