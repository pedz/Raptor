module Retain
  class Call < Base

    set_fetch_request "PMCB"
    set_fetch_required_fields(:queue_name, :center, :ppg,
                              :h_or_s, :signon, :password,
                              :pmpb_group_request)

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:pmpb_group_request)
        @fields[:pmpb_group_request] = [
                                        :problem,
                                        :branch,
                                        :country,
                                        :queue_name,
                                        :center,
                                        :h_or_s,
                                        :ppg,
                                        :cpu_type
                                       ]
      end
    end
    
    def pbc
      "%s,%s,%s" % [ problem, branch, country ]
    end
  end
end
