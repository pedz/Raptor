class ElementsController < ApplicationController
  before_filter :get_presentation
  before_filter :check_presentation, :except => [ :index, :show ]

  # GET /presentations/1/elements
  # GET /presentations/1/elements.xml
  def index
    @elements = @presentation.elements.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @elements }
    end
  end

  # GET /elements/1
  # GET /elements/1.xml
  def show
    @element = @presentation.elements.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @element }
    end
  end

  # GET /elements/new
  # GET /elements/new.xml
  def new
    @element = @presentation.elements.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @element }
    end
  end

  # GET /elements/1/edit
  def edit
    @element = @presentation.elements.find(params[:id])
  end

  # POST /elements
  # POST /elements.xml
  def create
    @element = @presentation.elements.build(params[:element])
    @element.owner_id = @application_user.id

    respond_to do |format|
      if @element.save
        flash[:notice] = 'Element was successfully created.'
        format.html { redirect_to presentation_element_path(@presentation, @element) }
        format.xml  { render :xml => @element, :status => :created, :location => @element }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /elements/1
  # PUT /elements/1.xml
  def update
    @element = @presentation.elements.find(params[:id])

    respond_to do |format|
      if @element.update_attributes(params[:element])
        flash[:notice] = 'Element was successfully updated.'
        format.html { redirect_to presentation_element_path(@presentation, @element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /elements/1
  # DELETE /elements/1.xml
  def destroy
    @element = @presentation.elements.find(params[:id])
    @element.destroy

    respond_to do |format|
      format.html { redirect_to(presentation_elements_url(@presentation)) }
      format.xml  { head :ok }
    end
  end

  private

  def get_presentation
    @presentation = Presentation.find(params[:presentation_id])
  end

  def check_presentation
    if @presentation.owner_id != @application_user.id
      flash[:error] = "Only owner of presentation can modify its elements"
      redirect_to(presentation_elements_url(@presentation))
    end
  end
end
