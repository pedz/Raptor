module Retain
  class QueuesController < RetainController
    def index
      @queues = Cached::Queue.find(:all).map do |q|
        q.to_combined
      end.sort
    end
  end
end
