class Retain::QueueInfosController < ApplicationController
  # GET /retain_queue_infos
  # GET /retain_queue_infos.xml
  def index
    @queue_infos = Retain::QueueInfo.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @retain_queue_infos }
    end
  end

  # GET /retain_queue_infos/1
  # GET /retain_queue_infos/1.xml
  def show
    @queue_info = Retain::QueueInfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @queue_info }
    end
  end

  # GET /retain_queue_infos/new
  # GET /retain_queue_infos/new.xml
  def new
    @queue_info = Retain::QueueInfo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @queue_info }
    end
  end

  # GET /retain_queue_infos/1/edit
  def edit
    @queue_info = Retain::QueueInfo.find(params[:id])
  end

  # POST /retain_queue_infos
  # POST /retain_queue_infos.xml
  def create
    @queue_info = Retain::QueueInfo.new(params[:retain_queue_info])

    respond_to do |format|
      if @queue_info.save
        flash[:notice] = 'Retain::QueueInfo was successfully created.'
        format.html { redirect_to(@queue_info) }
        format.xml  { render :xml => @queue_info, :status => :created, :location => @queue_info }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @queue_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retain_queue_infos/1
  # PUT /retain_queue_infos/1.xml
  def update
    @queue_info = Retain::QueueInfo.find(params[:id])

    respond_to do |format|
      if @queue_info.update_attributes(params[:retain_queue_info])
        flash[:notice] = 'Retain::QueueInfo was successfully updated.'
        format.html { redirect_to(@queue_info) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @queue_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retain_queue_infos/1
  # DELETE /retain_queue_infos/1.xml
  def destroy
    @queue_info = Retain::QueueInfo.find(params[:id])
    @queue_info.destroy

    respond_to do |format|
      format.html { redirect_to(retain_queue_infos_url) }
      format.xml  { head :ok }
    end
  end
end
