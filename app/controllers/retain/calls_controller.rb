module Retain
  class CallsController < RetainController
    # This is nested under queues.
    def index
      if (@queue = Combined::Queue.from_param(params[:queue_id])).nil?
        render :text => "h2 style='color:red'>Queue not found</h2>"
        return
      end

      respond_to do |format|
        format.html # index.html.erb
        # format.xml { render :xml => @queue.to_xml }
        format.json # { render :json => @queue.to_json }
      end
    end
  end
end
