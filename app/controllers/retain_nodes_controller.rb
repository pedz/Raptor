class RetainNodesController < ApplicationController
  # GET /retain_nodes
  # GET /retain_nodes.xml
  def index
    @retain_nodes = RetainNode.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @retain_nodes }
    end
  end

  # GET /retain_nodes/1
  # GET /retain_nodes/1.xml
  def show
    @retain_node = RetainNode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retain_node }
    end
  end

  # GET /retain_nodes/new
  # GET /retain_nodes/new.xml
  def new
    @retain_node = RetainNode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retain_node }
    end
  end

  # GET /retain_nodes/1/edit
  def edit
    @retain_node = RetainNode.find(params[:id])
  end

  # POST /retain_nodes
  # POST /retain_nodes.xml
  def create
    @retain_node = RetainNode.new(params[:retain_node])

    respond_to do |format|
      if @retain_node.save
        flash[:notice] = 'RetainNode was successfully created.'
        format.html { redirect_to(@retain_node) }
        format.xml  { render :xml => @retain_node, :status => :created, :location => @retain_node }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retain_node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retain_nodes/1
  # PUT /retain_nodes/1.xml
  def update
    @retain_node = RetainNode.find(params[:id])

    respond_to do |format|
      if @retain_node.update_attributes(params[:retain_node])
        flash[:notice] = 'RetainNode was successfully updated.'
        format.html { redirect_to(@retain_node) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @retain_node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retain_nodes/1
  # DELETE /retain_nodes/1.xml
  def destroy
    @retain_node = RetainNode.find(params[:id])
    @retain_node.destroy

    respond_to do |format|
      format.html { redirect_to(retain_nodes_url) }
      format.xml  { head :ok }
    end
  end
end
