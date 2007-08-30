
#
# Right now, the Fields class is just a place to put constants that
# mnemonically map to the data element fields.

module Retain
  class Fields

    ### include FieldConverters

    #
    # A hash used to create the getters and setters in request and
    # reply.  Also used to create upper case constant equivalents.
    #
    FIELD_DEFINITIONS = {
      :branch                     => [    2, :upper_ebcdic,  3 ],
      :country                    => [    3, :upper_ebcdic,  3 ],
      :problem                    => [    4, :upper_ebcdic,  5 ],
      :customer_number            => [   11, :upper_ebcdic,  7 ],
      :cpu_type                   => [   22, :ebcdic,        4 ],
      :queue_name                 => [   27, :upper_ebcdic,  6 ],
      :de32                       => [   32, :binary,        0 ],
      :center                     => [   41, :upper_ebcdic,  3 ],
      :nls_customer_name          => [  101, :nls,          30 ],
      :nls_contact_name           => [  102, :nls,          30 ],
      :nls_comments               => [  128, :nls,          56 ],
      :crit_sit                   => [  282, :upper_ebcdic,  1 ],
      :p_s_b                      => [  298, :upper_ebcdic,  1 ],
      :addtxt_line                => [  331, :ebcdic,       72 ],
      :alterable_format_text_line => [  340, :ebcdic,       72 ],
      :scs0_group_request         => [  528, :binary,        0 ],
      :ppg                        => [  550, :binary,        2 ],
      :call_search_result         => [  658, :ebcdic,        0 ],
      :symbol_of_call_record      => [  707, :binary,       86 ],
      :iris                       => [  930, :binary,       12 ],
      :h_or_s                     => [ 1135, :upper_ebcdic,  1 ],
      :signon                     => [ 1236, :upper_ebcdic,  6 ],
      :password                   => [ 1237, :upper_ebcdic,  8 ],
      :pmpb_group_request         => [ 1253, :binary,        0 ],
      :error_message              => [ 1384, :upper_ebcdic, 79 ],
      :information_text_line      => [ 1390, :upper_ebcdic, 72 ]
    }
    
    def initialize(fetch_fields = nil)
      @fetch_fields = fetch_fields
      @fields = Hash.new
    end
    
    # Convert each of the entries from the table above into a
    # constant.  These might not be used any more...
    #
    # Also create @@field_num_to_name and @@field_num_to_cvt.  These
    # might not get used either.
    #
    @@field_num_to_name   = Array.new
    @@field_num_to_cvt    = Array.new
    @@field_num_to_width  = Array.new
    
    FIELD_DEFINITIONS.each_pair do |k, v|
      index, convert, width = v
      const_set(k.to_s.upcase, index)
      @@field_num_to_name[index] = k
      @@field_num_to_cvt[index] =  convert
      @@field_num_to_width[index] = width
    end

    def self.sym_to_index(sym)
      FIELD_DEFINITIONS[sym][0]
    end

    def self.index_to_sym(index)
      @@field_num_to_name[index]
    end
    
    #
    # Create field getters and setters
    #
    FIELD_DEFINITIONS.each_pair do |k, v|
      index, convert, width = v
      eval "def #{k}; reader(#{index}, :#{convert}, #{width}); end", nil, __FILE__, __LINE__
      eval "def #{k}=(data); writer(#{index}, :#{convert}, #{width}, data); end", nil, __FILE__, __LINE__
    end

    def dump_fields
      @fields.each_pair do |k, v|
        puts "field:#{k} is #{v.value}"
      end
    end

    def delete(index)
      @fields.delete(index_or_sym_to_index(index))
    end

    def has_key?(index)
      @fields.has_key?(index_or_sym_to_index(index))
    end
    
    def [](index)
      @fields[index_or_sym_to_index(index)]
    end

    #
    # Used to set values received from retain into a field
    #
    def add_raw(index, value)
      index = index_or_sym_to_index(index)
      cvt = @@field_num_to_cvt[index]
      width = @@field_num_to_width[index]
      @fields[index] = Field.new(cvt, width, value, true)
    end

    def []=(index, value)
      index = index_or_sym_to_index(index)
      cvt = @@field_num_to_cvt[index]
      width = @@field_num_to_width[index]
      @fields[index] = Field.new(cvt, width, value)
    end
    
    def each_pair
      @fields.each_pair do |k, v|
        yield(k, v.value)
      end
    end
    
    private
    
    def index_or_sym_to_index(index)
      if index.is_a?(Symbol)
        Fields.sym_to_index(index)
      else
        index
      end
    end
    
    def reader(index, cvt, width)
      puts "reading #{index}"
      if f = @fields[index]
        puts "reading saved #{index} f.class is #{f.class}"
        return f.value
      elsif not @fetched
        puts "fetching fields for #{self.class}"
        @fetch_fields.call
        if f = @fields[index]
          return f.value
        end
        puts "something went wrong '#{@rc}'"
      end
      super.send sym
    end
    
    def writer(index, cvt, width, value)
      @fields[index] = Field.new(cvt, width, value)
    end
  end
end

### class String
###   include Retain::FieldConverters
### end
### 
### class Array
###   def ocvt(how)
###     self
###   end
### end
