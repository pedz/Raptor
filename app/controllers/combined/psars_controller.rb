class CombinedPsarsController < ApplicationController
  # GET /combined_psars
  # GET /combined_psars.xml
  def index
    @combined_psars = CombinedPsar.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @combined_psars }
    end
  end

  # GET /combined_psars/1
  # GET /combined_psars/1.xml
  def show
    @combined_psar = CombinedPsar.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @combined_psar }
    end
  end

  # GET /combined_psars/new
  # GET /combined_psars/new.xml
  def new
    @combined_psar = CombinedPsar.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @combined_psar }
    end
  end

  # GET /combined_psars/1/edit
  def edit
    @combined_psar = CombinedPsar.find(params[:id])
  end

  # POST /combined_psars
  # POST /combined_psars.xml
  def create
    @combined_psar = CombinedPsar.new(params[:combined_psar])

    respond_to do |format|
      if @combined_psar.save
        flash[:notice] = 'CombinedPsar was successfully created.'
        format.html { redirect_to(@combined_psar) }
        format.xml  { render :xml => @combined_psar, :status => :created, :location => @combined_psar }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @combined_psar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /combined_psars/1
  # PUT /combined_psars/1.xml
  def update
    @combined_psar = CombinedPsar.find(params[:id])

    respond_to do |format|
      if @combined_psar.update_attributes(params[:combined_psar])
        flash[:notice] = 'CombinedPsar was successfully updated.'
        format.html { redirect_to(@combined_psar) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @combined_psar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /combined_psars/1
  # DELETE /combined_psars/1.xml
  def destroy
    @combined_psar = CombinedPsar.find(params[:id])
    @combined_psar.destroy

    respond_to do |format|
      format.html { redirect_to(combined_psars_url) }
      format.xml  { head :ok }
    end
  end
end
