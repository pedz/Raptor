module Retain
  class Queue < Base
    def initialize(options = {})
      @options = options
      @fields = nil
      @logger = options[:logger] || RAILS_DEFAULT_LOGGER
    end

    def method_missing(sym)
      puts "queue method_missing: #{sym.to_s}"
      if @fields.nil?
        p = Request.new(:request => "PMCS")
        p.signon = Logon.instance.signon
        p.password = Logon.instance.password
        p.queue_name = @options[:queue_name].trim(6)
        p.center = @options[:center].trim(3)
        p.h_or_s = @options[:h_or_s] || "S"
        @temp = sendit(p, @options)
        @fields = @temp.fields
      end
      @fields.send sym
    end
  end
end
