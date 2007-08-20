module Retain
  class QueuesController < RetainController
    # GET /retain/queues
    # GET /retain/queues.xml
    def index
      @retain_queues = RetainQueue.find(:all)

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @retain_queues }
      end
    end

    # GET /retain/queues/1
    # GET /retain/queues/1.xml
    def show
      @retain_queue = RetainQueue.find(params[:id])
      @user = session[:user]
      @user = @user.retain_user
      r = Retain::Base.new(:signon => @user.retid,
                           :password => @user.password)
      queue = r.scs0(:queue_name => @retain_queue.queue_name,
                     :center => @retain_queue.center,
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
        format.xml  { render :xml => @retain_queue }
      end
    end

    # GET /retain/queues/new
    # GET /retain/queues/new.xml
    def new
      @retain_queue = RetainQueue.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @retain_queue }
      end
    end

    # GET /retain/queues/1/edit
    def edit
      @retain_queue = RetainQueue.find(params[:id])
    end

    # POST /retain/queues
    # POST /retain/queues.xml
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

    # PUT /retain/queues/1
    # PUT /retain/queues/1.xml
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

    # DELETE /retain/queues/1
    # DELETE /retain/queues/1.xml
    def destroy
      @retain_queue = RetainQueue.find(params[:id])
      @retain_queue.destroy

      respond_to do |format|
        format.html { redirect_to(queues_url) }
        format.xml  { head :ok }
      end
    end
  end
end
