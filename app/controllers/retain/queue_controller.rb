module Retain
  class QueueController < RetainController
    def show
      queue_name, center, h_or_s = params[:id].split(',')
      options = { :queue_name => queue_name, :center => center, :h_or_s => 'S' }
      options[:h_or_s] = h_or_s unless h_or_s.nil?
      @queue = Combined::Queue.new(options)
      @queue.mark_cache_invalid
      @calls = @queue.calls
    end
  end
end
