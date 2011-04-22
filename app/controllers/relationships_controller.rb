class RelationshipsController < ApplicationController
  # GET /relationships
  # GET /relationships.xml
  def index
    @relationships = Relationship.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @relationships }
    end
  end

  # GET /relationships/1
  # GET /relationships/1.xml
  def show
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @relationship }
    end
  end

  # GET /relationships/new
  # GET /relationships/new.xml
  def new
    @relationship = Relationship.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @relationship }
    end
  end

  # GET /relationships/1/edit
  def edit
    @relationship = Relationship.find(params[:id])
  end

  # POST /relationships
  # POST /relationships.xml
  def create
    options = params[:relationship]
    relationship_type = RelationshipType.find(options[:relationship_type_id])
    options[:element_name_type] = relationship_type.element_type.name_type
    options[:owner_id] = @application_user.id
    @relationship = Relationship.new(options)

    respond_to do |format|
      if @relationship.save
        flash[:notice] = 'Relationship was successfully created.'
        format.html { redirect_to(@relationship) }
        format.xml  { render :xml => @relationship, :status => :created, :location => @relationship }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /relationships/1
  # PUT /relationships/1.xml
  def update
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      if @relationship.update_attributes(params[:relationship])
        flash[:notice] = 'Relationship was successfully updated.'
        format.html { redirect_to(@relationship) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /relationships/1
  # DELETE /relationships/1.xml
  def destroy
    @relationship = Relationship.find(params[:id])
    @relationship.destroy

    respond_to do |format|
      format.html { redirect_to(relationships_url) }
      format.xml  { head :ok }
    end
  end

  def container_name_set
    render :partial => "relationship_types", :locals => { :container_name_id => params[:container_name_id] }
  end

  def relationship_type_set
    render :partial => "valid_elements", :locals => { :relationship_type_id => params[:relationship_type_id] }
  end
end
