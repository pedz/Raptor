class RetainNodeSelectorsController < ApplicationController
  before_filter :admin_only

  # GET /retain_node_selectors
  # GET /retain_node_selectors.xml
  def index
    @retain_node_selectors = RetainNodeSelector.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @retain_node_selectors }
    end
  end

  # GET /retain_node_selectors/1
  # GET /retain_node_selectors/1.xml
  def show
    @retain_node_selector = RetainNodeSelector.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retain_node_selector }
    end
  end

  # GET /retain_node_selectors/new
  # GET /retain_node_selectors/new.xml
  def new
    @retain_node_selector = RetainNodeSelector.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retain_node_selector }
    end
  end

  # GET /retain_node_selectors/1/edit
  def edit
    @retain_node_selector = RetainNodeSelector.find(params[:id])
  end

  # POST /retain_node_selectors
  # POST /retain_node_selectors.xml
  def create
    @retain_node_selector = RetainNodeSelector.new(params[:retain_node_selector])

    respond_to do |format|
      if @retain_node_selector.save
        flash[:notice] = 'RetainNodeSelector was successfully created.'
        format.html { redirect_to(@retain_node_selector) }
        format.xml  { render :xml => @retain_node_selector, :status => :created, :location => @retain_node_selector }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retain_node_selector.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retain_node_selectors/1
  # PUT /retain_node_selectors/1.xml
  def update
    @retain_node_selector = RetainNodeSelector.find(params[:id])

    respond_to do |format|
      if @retain_node_selector.update_attributes(params[:retain_node_selector])
        flash[:notice] = 'RetainNodeSelector was successfully updated.'
        format.html { redirect_to(@retain_node_selector) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @retain_node_selector.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retain_node_selectors/1
  # DELETE /retain_node_selectors/1.xml
  def destroy
    @retain_node_selector = RetainNodeSelector.find(params[:id])
    @retain_node_selector.destroy

    respond_to do |format|
      format.html { redirect_to(retain_node_selectors_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def admin_only
    unless admin?
      flash[:notice] = "Not Permitted"
      redirect_to(:controller => "welcome", :action => "index", :status => 401)
    end
  end
end
