module Retain
  class Pmdr < Sdi
    set_fetch_request "PMDR"
    set_required_fields(:signon, :password,
                        :group_request)

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [
                                   :name,
                                   :queue_name,
                                   :center,
                                   :h_or_s,
                                   :absorb_support_list,
                                   :num_primary_list,
                                   :num_secondary_list,
                                   :num_absorb_list,
                                   :primary_support_list,
                                   :secondary_support_list
                                  ]
      end
    end
  end
end
