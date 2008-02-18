module Retain
  class QqController < RetainController
    #
    # Mostly test and debug code.  This does a "qq" call which gets
    # some characteristics of a queue.  I could not find anything
    # useful here.
    #
    def show
      queue_name, center, h_or_s = params[:id].split(',')
      options = {
        :queue_name => queue_name.upcase.strip,
        :center => center
      }
      if h_or_s.nil?
        options[:h_or_s] = h_or_s
      else
        options[:h_or_s] = 'S'
      end
      @query = Retain::Qq.new(options)
    end
  end
end
