module Retain
  class Pmcb < Sdi
    
    set_fetch_request "PMCB"
    set_required_fields(:queue_name, :center, :ppg,
                        :h_or_s, :signon, :password,
                        :group_request)

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [
                                   :problem,
                                   :branch,
                                   :country,
                                   :cpu_type,
                                   :component_id,
                                   :comments,
                                   :nls_customer_name,
                                   :nls_contact_name,
                                   :contact_phone_1,
                                   :contact_phone_2,
                                   :priority,
                                   :category,
                                  ]
      end
    end
  end
end
