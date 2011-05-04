class ArgumentTypesController < ApplicationController
  # GET /argument_types
  # GET /argument_types.xml
  def index
    @argument_types = ArgumentType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @argument_types }
    end
  end

  # GET /argument_types/1
  # GET /argument_types/1.xml
  def show
    @argument_type = ArgumentType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @argument_type }
    end
  end

  # GET /argument_types/new
  # GET /argument_types/new.xml
  def new
    @argument_type = ArgumentType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @argument_type }
    end
  end

  # GET /argument_types/1/edit
  def edit
    @argument_type = ArgumentType.find(params[:id])
  end

  # POST /argument_types
  # POST /argument_types.xml
  def create
    @argument_type = ArgumentType.new(params[:argument_type])

    respond_to do |format|
      if @argument_type.save
        flash[:notice] = 'ArgumentType was successfully created.'
        format.html { redirect_to(@argument_type) }
        format.xml  { render :xml => @argument_type, :status => :created, :location => @argument_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @argument_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /argument_types/1
  # PUT /argument_types/1.xml
  def update
    @argument_type = ArgumentType.find(params[:id])

    respond_to do |format|
      if @argument_type.update_attributes(params[:argument_type])
        flash[:notice] = 'ArgumentType was successfully updated.'
        format.html { redirect_to(@argument_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @argument_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /argument_types/1
  # DELETE /argument_types/1.xml
  def destroy
    @argument_type = ArgumentType.find(params[:id])
    @argument_type.destroy

    respond_to do |format|
      format.html { redirect_to(argument_types_url) }
      format.xml  { head :ok }
    end
  end
end
