module Retain
  class QqController < RetainController
    def show
      queue_name, center, h_or_s = params[:id].split(',')
      options = { :queue_name => queue_name, :center => center }
      if h_or_s.nil?
        options[:h_or_s] = h_or_s
      else
        options[:h_or_s] = 'S'
      end
      @query = Retain::Qq.new(options)
    end
  end
end
