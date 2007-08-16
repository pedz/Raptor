
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
      "branch"                     => [    2, true ],
      "country"                    => [    3, true ],
      "problem"                    => [    4, true ],
      "customer_number"            => [   11, true ],
      "queue_name"                 => [   27, true ],
      "de32"                       => [   32, false],
      "center"                     => [   41, true ],
      "addtxt_line"                => [  331, true ],
      "alterable_format_text_line" => [  340, true ],
      "call_search_result"         => [  658, true ],
      "symbol_of_call_record"      => [  707, true ],
      "iris"                       => [  930, false],
      "h_or_s"                     => [ 1135, true ],
      "signon"                     => [ 1236, true ],
      "password"                   => [ 1237, true ],
      "group_request"              => [ 1253, false],
      "error_message"              => [ 1384, true ],
      "information_text_line"      => [ 1390, true ]
    }
    
    FIELD_DEFINITIONS.each_pair do |k, v|
      index, convert = v
      const_set(k.upcase, index)
    end
  end
end
