module Retain
  class Scs0 < Sdi

    set_fetch_request "SCS0"
    set_required_fields :queue_name, :center, :requested_elements
    set_optional_fields :h_or_s
    
    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:requested_elements)
        @fields[:requested_elements] = [
                                        :queue_name,
                                        :center,
                                        :h_or_s,
                                        :ppg,
                                        :problem,
                                        :branch,
                                        :country,
                                        :priority,
                                        :p_s_b,
                                        :comments,
                                        :nls_customer_name,
                                        :cstatus
                                       ]
      end
    end
  end
end
