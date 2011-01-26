class TeamQueuesController < ApplicationController
  # GET /team_queues
  # GET /team_queues.xml
  def index
    @team_queues = TeamQueue.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @team_queues }
    end
  end

  # GET /team_queues/1
  # GET /team_queues/1.xml
  def show
    @team_queue = TeamQueue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team_queue }
    end
  end

  # GET /team_queues/new
  # GET /team_queues/new.xml
  def new
    @team_queue = TeamQueue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team_queue }
    end
  end

  # GET /team_queues/1/edit
  def edit
    @team_queue = TeamQueue.find(params[:id])
  end

  # POST /team_queues
  # POST /team_queues.xml
  def create
    @team_queue = TeamQueue.new(params[:team_queue])

    respond_to do |format|
      if @team_queue.save
        flash[:notice] = 'TeamQueue was successfully created.'
        format.html { redirect_to(@team_queue) }
        format.xml  { render :xml => @team_queue, :status => :created, :location => @team_queue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @team_queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /team_queues/1
  # PUT /team_queues/1.xml
  def update
    @team_queue = TeamQueue.find(params[:id])

    respond_to do |format|
      if @team_queue.update_attributes(params[:team_queue])
        flash[:notice] = 'TeamQueue was successfully updated.'
        format.html { redirect_to(@team_queue) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team_queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /team_queues/1
  # DELETE /team_queues/1.xml
  def destroy
    @team_queue = TeamQueue.find(params[:id])
    @team_queue.destroy

    respond_to do |format|
      format.html { redirect_to(team_queues_url) }
      format.xml  { head :ok }
    end
  end
end
