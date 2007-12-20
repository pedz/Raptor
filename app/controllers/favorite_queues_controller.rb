module Retain
  class FavoriteQueuesController < RetainController
    # GET /favorite_queues
    # GET /favorite_queues.xml
    def index
      if admin?
        @favorite_queues = FavoriteQueue.find(:all)
      else
        @favorite_queues = session[:user].favorite_queues
      end
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @favorite_queues }
      end
    end
    
    # GET /favorite_queues/1
    # GET /favorite_queues/1.xml
    def show
      @favorite_queue = FavoriteQueue.find(params[:id])
      @pmrs = []
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @favorite_queue }
      end
    end
    
    # GET /favorite_queues/new
    # GET /favorite_queues/new.xml
    def new
      @favorite_queue = FavoriteQueue.new
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @favorite_queue }
      end
    end
    
    # GET /favorite_queues/1/edit
    def edit
      @favorite_queue = FavoriteQueue.find(params[:id])
    end
    
    # POST /favorite_queues
    # POST /favorite_queues.xml
    def create
      @favorite_queue = FavoriteQueue.new(params[:favorite_queue])
      @favorite_queue.user = session[:user]
      respond_to do |format|
        if @favorite_queue.save
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
      @favorite_queue = FavoriteQueue.find(params[:id])
      
      respond_to do |format|
        if @favorite_queue.update_attributes(params[:favorite_queue])
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
      @favorite_queue = FavoriteQueue.find(params[:id])
      @favorite_queue.destroy
      
      respond_to do |format|
        format.html { redirect_to(queues_url) }
        format.xml  { head :ok }
      end
    end
  end
end
