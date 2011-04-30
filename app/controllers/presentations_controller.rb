class PresentationsController < ApplicationController
  # GET /presentations
  # GET /presentations.xml
  def index
    @presentations = Presentation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @presentations }
    end
  end

  # GET /presentations/1
  # GET /presentations/1.xml
  def show
    @presentation = Presentation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @presentation }
    end
  end

  # GET /presentations/new
  # GET /presentations/new.xml
  def new
    @presentation = Presentation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @presentation }
    end
  end

  # GET /presentations/1/edit
  def edit
    @presentation = Presentation.find(params[:id])
  end

  # POST /presentations
  # POST /presentations.xml
  def create
    @presentation = Presentation.new(params[:presentation])
    @presentation.owner_id = @application_user.id

    respond_to do |format|
      if @presentation.save
        flash[:notice] = 'Presentation was successfully created.'
        format.html { redirect_to(@presentation) }
        format.xml  { render :xml => @presentation, :status => :created, :location => @presentation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @presentation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /presentations/1
  # PUT /presentations/1.xml
  def update
    @presentation = Presentation.find(params[:id])

    # We want to have three possible outcomes.
    # 1) The change is allowed and it succeeds (allowed == true and
    #    result == true)
    # 2) The change is allowed but it fails (allowed == true and
    #    result != true)
    # 3) The change is not allowed. (allowed != true)

    # What is allowed?
    # 1) A user that owns the presentation can change its attributes.  This is
    #    if @presentation.owner_id == @application_user.id and copy is false.
    # 2) A user that owns the presentation can changes its name and make a
    #    copy (which will cause copies of the elements that belong to
    #    the presentation to be created as well)  This is if @presentation.owner_id ==
    #    @application_user.id and copy is true.
    # 3) A user that does not own the presentation can create a new copy of
    #    the presentation just like in #2 except the new presentation will be owned by
    #    the current user.  This is if @presentation.owner_id !=
    #    @application_user.id and copy is true.
    allowed = false
    result = false
    if params[:copy] == true || params[:copy] == "true"
      allowed = true
      new_copy = Presentation.new(params[:presentation])
      new_copy.owner_id = @application_user.id
      # See if we can save the new presentation
      if (result = new_copy.save)
        # New presentation is saved, now copy elements from original presentation to
        # new presentation.
        @presentation.elements.each do |element|
          new_element = new_copy.elements.build(element.attributes)
          new_element.owner_id = @application_user.id
          # We ignore the result of the following save.  It should
          # never fail and if it does, we have a new presentation created and
          # some of the elements didn't get copied but there isn't
          # really a way to convey that to the user.
          new_element.save
        end
        @presentation = new_copy        # redirect to new copy
      else
        # new_copy has the error messages.  Move them to @presentation because
        # we want to call edit again with the same record but have the
        # error messages displayed.
        new_copy.errors.each_error do |attr, err|
          @presentation.errors.add(attr, err)
        end
      end
    elsif @presentation.owner_id == @application_user.id
      allowed = true
      result = @presentation.update_attributes(params[:presentation])
    end
    respond_to do |format|
      if allowed
        if result
          flash[:notice] = 'Presentation was successfully updated.'
          format.html { redirect_to(@presentation) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @presentation.errors, :status => :unprocessable_entity }
        end
      else
        @presentation.errors.add_to_base "You are not the owner of the presentation so you must make a copy"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @presentation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /presentations/1
  # DELETE /presentations/1.xml
  def destroy
    @presentation = Presentation.find(params[:id])
    if @presentation.owner_id == @application_user.id
      @presentation.destroy
      respond_to do |format|
        format.html { redirect_to(presentations_url) }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html { render :file => "public/401.html", :status => :unauthorized }
        format.xml { render :xml => @presentation.errors, :status => :unauthorized }
      end
    end
  end
end
