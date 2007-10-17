module Retain
  class Pmpb < Sdi
    set_fetch_request "PMPB"
    set_required_fields(:problem, :branch, :country,
                        :signon, :password,
                        :pmpb_group_request)
    set_optional_fields(:beginning_page_number)

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:pmpb_group_request)
        @fields[:pmpb_group_request] = [
                                        :queue_name,
                                        :center,
                                        :h_or_s,
                                        :ppg,
                                        :priority,
                                        :severity,
                                        :p_s_b,
                                        :comments,
                                        :customer_name,
                                        :cstatus,
                                        :nls_scratch_pad_1,
                                        :nls_scratch_pad_2,
                                        :nls_scratch_pad_3,
                                        :addtxt_lines,
                                        :information_text_lines,
                                        :alterable_format_text_lines
                                       ]
      end
    end
  end
end
