module Retain
  class QueueController < RetainController
    def show
      queue_name, center, dummy, h_or_s = /([^,]+),(...)(:([hsHS]))?/.match(params[:queue_spec])[1..4]
      options = { :queue_name => queue_name, :center => center }
      options[:h_or_s] = h_or_s unless h_or_s.nil?
      @queue = Retain::Queue.new(options)
      @calls = @queue.calls
      logger.debug("#{@calls.class}")
      logger.debug("#{@calls[0].class}") if @calls.is_a?(Array)
    end
  end
end
