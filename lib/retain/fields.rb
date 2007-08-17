
#
# Right now, the Fields class is just a place to put constants that
# mnemonically map to the data element fields.

module Retain
  class Fields
    #
    # A hash used to create the getters and setters in request and
    # reply.  Also used to create upper case constant equivalents.
    #
    FIELD_DEFINITIONS = {
      "branch"                     => [    2, :ebcdic ],
      "country"                    => [    3, :ebcdic ],
      "problem"                    => [    4, :ebcdic ],
      "customer_number"            => [   11, :ebcdic ],
      "queue_name"                 => [   27, :ebcdic ],
      "de32"                       => [   32, :binary],
      "center"                     => [   41, :ebcdic ],
      "addtxt_line"                => [  331, :ebcdic ],
      "alterable_format_text_line" => [  340, :ebcdic ],
      "scs0_group_request"         => [  528, :binary],
      "call_search_result"         => [  658, :ebcdic ],
      "symbol_of_call_record"      => [  707, :ebcdic ],
      "iris"                       => [  930, :binary],
      "h_or_s"                     => [ 1135, :ebcdic ],
      "signon"                     => [ 1236, :ebcdic ],
      "password"                   => [ 1237, :ebcdic ],
      "pmpb_group_request"         => [ 1253, :binary],
      "error_message"              => [ 1384, :ebcdic ],
      "information_text_line"      => [ 1390, :ebcdic ],
      "NLS_customer_name"          => [  101, :nls ],
      "NLS_contact_name"           => [  102, :nls ],
      "NLS_comments"               => [  128, :nls ],
    }
    
    FIELD_DEFINITIONS.each_pair do |k, v|
      index, convert = v
      const_set(k.upcase, index)
    end

    def self.icvt(how)
      case how
      when :ebcdic then ".upcase.ebcdic"
      when :nls then ".upcase.ebcdic"
      when :binary then ""
      end
    end

    def self.ocvt(how)
      case how
      when :ebcdic then ".ascii"
      when :nls then ".ascii"
      when :binary then ""
      end
    end
  end
end
