module Retain
  class QsController < RetainController
    def show
      queue_name, center, h_or_s = params[:id].split(',')
      options = { :queue_name => queue_name, :center => center }
      options[:h_or_s] = h_or_s unless h_or_s.nil?
      @queue = Retain::Queue.new(options)
      @tuples = []
      @queue.calls.each do |call|
        options = {
          :queue_name => call.queue_name,
          :center => call.center,
          :ppg => call.ppg,
          :h_or_s => call.h_or_s,
          :p_s_b => call.p_s_b
        }
        tuple =  call_to_all(options)
        @tuples << tuple
      end
    end
  end
end
