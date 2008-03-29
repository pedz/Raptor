module Retain
  class Pmpb < Sdi
    set_fetch_request "PMPB"
    set_required_fields(:problem, :branch, :country,
                        :signon, :password,
                        :group_request)
    set_optional_fields(:beginning_page_number)

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [[
                                    :queue_name,
                                    :center,
                                    :h_or_s,
                                    :ppg,
                                    :priority,
                                    :severity,
                                    :p_s_b,
                                    :comments,
                                    :nls_customer_name,
                                    :cstatus,
                                    :nls_scratch_pad_1,
                                    :nls_scratch_pad_2,
                                    :nls_scratch_pad_3,
                                    :addtxt_lines,
                                    :information_text_lines,
                                    :alterable_format_lines
                                   ]]
      end
    end
  end
end
