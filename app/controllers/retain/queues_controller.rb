class RetainQueuesController < RetainController
  # GET /retain/queues
  # GET /retain/queues.xml
  def index
    @queues = RetainQueue.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @queues }
    end
  end

  # GET /retain/queues/1
  # GET /retain/queues/1.xml
  def show
    @queue = RetainQueue.find(params[:id])
    @user = session[:user]
    @user = @user.user
    r = Retain::Base.new(:signon => @user.retid,
                         :password => @user.password)
    queue = r.scs0(:queue_name => @queue.queue_name,
                   :center => @queue.center,
                   :scs0_group_request => [
                                           :problem,
                                           :branch,
                                           :country,
                                           :NLS_comments,
                                           :NLS_customer_name,
                                           :NLS_contact_name
                                          ])
    @pmrs = queue.fields.de32

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @queue }
    end
  end

  # GET /retain/queues/new
  # GET /retain/queues/new.xml
  def new
    @queue = RetainQueue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @queue }
    end
  end

  # GET /retain/queues/1/edit
  def edit
    @queue = RetainQueue.find(params[:id])
  end

  # POST /retain/queues
  # POST /retain/queues.xml
  def create
    @queue = RetainQueue.new(params[:queue])
    @queue.user = session[:user]
    respond_to do |format|
      if @queue.save
        flash[:notice] = 'RetainQueue was successfully created.'
        format.html { redirect_to(@queue) }
        format.xml  { render :xml => @queue, :status => :created, :location => @queue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retain/queues/1
  # PUT /retain/queues/1.xml
  def update
    @queue = RetainQueue.find(params[:id])

    respond_to do |format|
      if @queue.update_attributes(params[:queue])
        flash[:notice] = 'RetainQueue was successfully updated.'
        format.html { redirect_to(@queue) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retain/queues/1
  # DELETE /retain/queues/1.xml
  def destroy
    @queue = RetainQueue.find(params[:id])
    @queue.destroy

    respond_to do |format|
      format.html { redirect_to(queues_url) }
      format.xml  { head :ok }
    end
  end
end
