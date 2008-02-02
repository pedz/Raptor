module Retain
  class FavoriteQueuesController < RetainController
    # GET /favorite_queues
    # GET /favorite_queues.xml
    def index
      if admin?
        # Untested
        @favorite_queues = Combined::FavoriteQueue.find(:all)
      else
        @favorite_queues = session[:user].favorite_queues.map { |queue|
          Combined::FavoriteQueue.new(queue)
        }
      end
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @favorite_queues }
      end
    end
    
    # GET /favorite_queues/1
    # GET /favorite_queues/1.xml
    def show
      @favorite_queue = Combined::FavoriteQueue.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @favorite_queue }
      end
    end
    
    # GET /favorite_queues/new
    # GET /favorite_queues/new.xml
    def new
      retid = session[:user].retusers[0].retid
      registration = Combined::Registration.find_by_signon(retid) ||
        Combined::Registration.new(:signon => retid)
      default_center = registration.default_center
      default_h_or_s = registration.default_h_or_s
      o = {
        :center => default_center,
        :h_or_s => default_h_or_s
      }
      queue = Combined::Queue.new(o)
      @favorite_queue = Combined::FavoriteQueue.new(:queue => queue)

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @favorite_queue }
      end
    end
    
    # GET /favorite_queues/1/edit
    def edit
      @favorite_queue = Combined::FavoriteQueue.find(params[:id])
    end
    
    # POST /favorite_queues
    # POST /favorite_queues.xml
    def create
      queue_options = params[:combined_queue]
      # The favorite queue is new -- that much is sure.  But the queue
      # might already exist.
      queue = Combined::Queue.find(:first, :conditions => queue_options) ||
        Combined::Queue.new(queue_options)
      @favorite_queue = Combined::FavoriteQueue.new(:queue => queue,
                                                    :user => session[:user])

      if ! (queue_valid = Retain::Cq.check_queue(queue_options.symbolize_keys))
        flash[:error] = "Queue is not valid"
      end

      respond_to do |format|
        if queue_valid && @favorite_queue.save
          flash[:notice] = 'FavoriteQueue was successfully created.'
          format.html { redirect_to(@favorite_queue) }
          format.xml  { render :xml => @favorite_queue, :status => :created, :location => @favorite_queue }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @favorite_queue.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /favorite_queues/1
    # PUT /favorite_queues/1.xml
    def update
      # this is an odd case.  We do not actually want to change the
      # attributes of the queue because other people may be pointing
      # to the queue as their favorite queue.  It would also confused
      # a lot of other things like the calls assoicated with the
      # queue.
      #
      # So, we find or create a new queue with the new parameters and
      # then associate the favorite queue with this queue.
      #
      queue_options = params[:combined_queue]
      queue = Combined::Queue.find(:first, :conditions => queue_options) ||
        Combined::Queue.new(queue_options)
      @favorite_queue = Combined::FavoriteQueue.find(params[:id])
      @favorite_queue.queue = queue

      if ! (queue_valid = Retain::Cq.check_queue(queue_options.symbolize_keys))
        flash[:error] = "Queue is not valid"
      end
      
      respond_to do |format|
        if queue_valid && @favorite_queue.save
          flash[:notice] = 'FavoriteQueue was successfully updated.'
          format.html { redirect_to(@favorite_queue) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @favorite_queue.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /favorite_queues/1
    # DELETE /favorite_queues/1.xml
    def destroy
      @favorite_queue = Combined::FavoriteQueue.find(params[:id])
      @favorite_queue.destroy
      
      respond_to do |format|
        format.html { redirect_to(combined_favorite_queues_url) }
        format.xml  { head :ok }
      end
    end
  end
end
