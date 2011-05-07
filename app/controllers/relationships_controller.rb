class RelationshipsController < ApplicationController
  layout "configuration"

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
    options[:item_type] = relationship_type.item_type.name_type
    @relationship = Relationship.new(options)
    begin
      save_result = @relationship.save
    rescue Exception => e
      set_errors(e)
      save_result = false
    end
    respond_to do |format|
      if save_result
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
    begin
      save_result = @relationship.update_attributes(params[:relationship])
    rescue Exception => e
      set_errors(e)
      save_result = false
    end
    respond_to do |format|
      if save_result
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
    render :partial => "valid_items", :locals => { :relationship_type_id => params[:relationship_type_id] }
  end

  private

  def set_errors(e)
    if e.message.match('"no_cycles_check"')
      @relationship.errors.add_to_base("Adding this will create a cycle in the decedents")
    elsif e.message.match('"uq_relationship_tuple"')
      @relationship.errors.add_to_base("This relationship already exists")
    elsif e.message.match('"fk_relationships_container_name"')
      @relationship.errors.add(:container_type_id, "Container id is not valid")
    elsif e.message.match('"fk_relationships_relationship_type"')
      @relationship.errors.add(:association_type_id, "Association type id is not valid")
    else
      raise
    end
  end
end
