module Retain
  class FavoriteQueuesController < RetainController
    # GET /favorite_queues
    # GET /favorite_queues.xml
    def index
      if admin?
        @retain_favorite_queues = Retain::FavoriteQueue.find(:all)
      else
        @retain_favorite_queues = session[:user].retain_favorite_queues
      end
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @retain_favorite_queues }
      end
    end
    
    # GET /favorite_queues/1
    # GET /favorite_queues/1.xml
    def show
      @retain_favorite_queue = Retain::FavoriteQueue.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @retain_favorite_queue }
      end
    end
    
    # GET /favorite_queues/new
    # GET /favorite_queues/new.xml
    def new
      @retain_favorite_queue = Retain::FavoriteQueue.new
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @retain_favorite_queue }
      end
    end
    
    # GET /favorite_queues/1/edit
    def edit
      @retain_favorite_queue = Retain::FavoriteQueue.find(params[:id])
    end
    
    # POST /favorite_queues
    # POST /favorite_queues.xml
    def create
      options = params[:retain_favorite_queue]
      @retain_favorite_queue = Retain::FavoriteQueue.new(options)

      if ! (queue_valid = Retain::Cq.check_queue(options.symbolize_keys))
        flash[:error] = "Queue is not valid"
      end

      @retain_favorite_queue.user = session[:user]
      respond_to do |format|
        if queue_valid && @retain_favorite_queue.save
          flash[:notice] = 'FavoriteQueue was successfully created.'
          format.html { redirect_to(@retain_favorite_queue) }
          format.xml  { render :xml => @retain_favorite_queue, :status => :created, :location => @retain_favorite_queue }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @retain_favorite_queue.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /favorite_queues/1
    # PUT /favorite_queues/1.xml
    def update
      @retain_favorite_queue = Retain::FavoriteQueue.find(params[:id])
      
      respond_to do |format|
        if @retain_favorite_queue.update_attributes(params[:retain_favorite_queue])
          flash[:notice] = 'FavoriteQueue was successfully updated.'
          format.html { redirect_to(@retain_favorite_queue) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @retain_favorite_queue.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /favorite_queues/1
    # DELETE /favorite_queues/1.xml
    def destroy
      @retain_favorite_queue = Retain::FavoriteQueue.find(params[:id])
      @retain_favorite_queue.destroy
      
      respond_to do |format|
        format.html { redirect_to(retain_favorite_queues_url) }
        format.xml  { head :ok }
      end
    end
  end
end
