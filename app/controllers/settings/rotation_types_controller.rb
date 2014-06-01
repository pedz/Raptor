module Settings
  class RotationTypesController < ApplicationController
    before_filter :get_rotation_group
    layout "settings"
    
    # GET /rotation_types
    # GET /rotation_types.xml
    def index
      @rotation_types = @rotation_group.rotation_types.all(:order => :name)

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @rotation_types }
      end
    end

    # GET /rotation_types/1
    # GET /rotation_types/1.xml
    def show
      @rotation_type = @rotation_group.rotation_types.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @rotation_type }
      end
    end

    # GET /rotation_types/new
    # GET /rotation_types/new.xml
    def new
      @rotation_type = @rotation_group.rotation_types.build

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @rotation_type }
      end
    end

    # GET /rotation_types/1/edit
    def edit
      @rotation_type = @rotation_group.rotation_types.find(params[:id])
    end

    # POST /rotation_types
    # POST /rotation_types.xml
    def create
      @rotation_type = @rotation_group.rotation_types.build(params[:rotation_type])

      respond_to do |format|
        if @rotation_type.save
          format.html { redirect_to([:settings, @rotation_group, @rotation_type], :notice => 'RotationType was successfully created.') }
          format.xml  { render :xml => @rotation_type, :status => :created, :location => @rotation_type }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @rotation_type.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /rotation_types/1
    # PUT /rotation_types/1.xml
    def update
      @rotation_type = @rotation_group.rotation_types.find(params[:id])

      respond_to do |format|
        if @rotation_type.update_attributes(params[:rotation_type])
          format.html { redirect_to([:settings, @rotation_group, @rotation_type], :notice => 'RotationType was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @rotation_type.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /rotation_types/1
    # DELETE /rotation_types/1.xml
    def destroy
      @rotation_type = @rotation_group.rotation_types.find(params[:id])
      @rotation_type.destroy

      respond_to do |format|
        format.html { redirect_to(settings_rotation_group_rotation_types_url(@rotation_group)) }
        format.xml  { head :ok }
      end
    end

    private

    def get_rotation_group
      @rotation_group = RotationGroup.find(params[:rotation_group_id])
    end
  end
end
