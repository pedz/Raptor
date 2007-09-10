module Retain
  class CallController < RetainController
    def show
      words = params[:call_spec].split(',')
      options = {
        :queue_name => words[0],
        :center => words[1],
        :ppg => words.last
      }
      if words.length == 4
        options[:h_or_s] = words[2]
      end
      @call = Retain::Call.new(options)
      logger.debug("#{@call.problem},#{@call.branch},#{@call.country}")
      @pmr = Retain::Pmr.new(:problem => @call.problem,
                             :branch => @call.branch,
                             :country => @call.country)
    end
  end
end
