class RetainQueuesController < RetainController
  # GET /retain_queues
  # GET /retain_queues.xml
  def index
    @retain_queues = RetainQueue.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @retain_queues }
    end
  end

  # GET /retain_queues/1
  # GET /retain_queues/1.xml
  def show
    @retain_queue = RetainQueue.find(params[:id])
    @user = session[:user]
    @retain_user = @user.retain_user
    r = Retain::Base.new
    f = r.login(@retain_user)
    @pmrs = r.cs(@retain_queue)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retain_queue }
    end
  end

  # GET /retain_queues/new
  # GET /retain_queues/new.xml
  def new
    @retain_queue = RetainQueue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retain_queue }
    end
  end

  # GET /retain_queues/1/edit
  def edit
    @retain_queue = RetainQueue.find(params[:id])
  end

  # POST /retain_queues
  # POST /retain_queues.xml
  def create
    @retain_queue = RetainQueue.new(params[:retain_queue])
    @retain_queue.user = session[:user]
    respond_to do |format|
      if @retain_queue.save
        flash[:notice] = 'RetainQueue was successfully created.'
        format.html { redirect_to(@retain_queue) }
        format.xml  { render :xml => @retain_queue, :status => :created, :location => @retain_queue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retain_queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retain_queues/1
  # PUT /retain_queues/1.xml
  def update
    @retain_queue = RetainQueue.find(params[:id])

    respond_to do |format|
      if @retain_queue.update_attributes(params[:retain_queue])
        flash[:notice] = 'RetainQueue was successfully updated.'
        format.html { redirect_to(@retain_queue) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @retain_queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retain_queues/1
  # DELETE /retain_queues/1.xml
  def destroy
    @retain_queue = RetainQueue.find(params[:id])
    @retain_queue.destroy

    respond_to do |format|
      format.html { redirect_to(retain_queues_url) }
      format.xml  { head :ok }
    end
  end
end
