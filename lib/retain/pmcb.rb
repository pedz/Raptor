module Retain
  class Pmcb < Sdi
    
    set_fetch_request "PMCB"
    set_required_fields(:queue_name, :center, :ppg,
                        :h_or_s, :signon, :password,
                        :pmpb_group_request)

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:pmpb_group_request)
        @fields[:pmpb_group_request] = [
                                        :problem,
                                        :branch,
                                        :country,
                                        :cpu_type,
                                        :comp_id_or_alias,
                                        :comments,
                                        :nls_customer_name,
                                        :nls_contact_name,
                                        :contact_phone_1,
                                        :contact_phone_2,
                                        :priority,
                                        :category
                                       ]
      end
    end
  end
end
