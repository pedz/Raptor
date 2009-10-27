# -*- coding: utf-8 -*-

module Combined
  class QueuesController < Retain::RetainController
    def index
      @combined_queues = Combined::Queues.find(:all)
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @combined_psars }
      end
    end

    def show
      begin
        @combined_queue = Combined::Queue.from_param!(params[:id], signon_user)
        @combined_queue.mark_cache_invalid
        @calls = @combined_queue.calls
      rescue QueueNotFound
        flash[:error] = "Queue not found"
      end
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @combined_queue.to_xml(:include => :calls) }
      end
    end
  end
end
