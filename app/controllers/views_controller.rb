# -*- coding: utf-8 -*-
class ViewsController < ApplicationController
  # GET /views
  # GET /views.xml
  def index
    @views = View.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @views }
    end
  end

  # GET /views/1
  # GET /views/1.xml
  def show
    @view = View.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @view }
    end
  end

  # GET /views/new
  # GET /views/new.xml
  def new
    @view = View.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @view }
    end
  end

  # GET /views/1/edit
  def edit
    @view = View.find(params[:id])
  end

  # POST /views
  # POST /views.xml
  def create
    @view = View.new(params[:view])
    @view.owner_id = @application_user.id

    respond_to do |format|
      if @view.save
        flash[:notice] = 'View was successfully created.'
        format.html { redirect_to(@view) }
        format.xml  { render :xml => @view, :status => :created, :location => @view }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @view.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /views/1
  # PUT /views/1.xml
  def update
    @view = View.find(params[:id])

    # We want to have three possible outcomes.
    # 1) The change is allowed and it succeeds (allowed == true and
    #    result == true)
    # 2) The change is allowed but it fails (allowed == true and
    #    result != true)
    # 3) The change is not allowed. (allowed != true)

    # What is allowed?
    # 1) A user that owns the view can change its attributes.  This is
    #    if @view.owner_id == @application_user.id and copy is false.
    # 2) A user that owns the view can changes its name and make a
    #    copy (which will cause copies of the elements that belong to
    #    the view to be created as well)  This is if @view.owner_id ==
    #    @application_user.id and copy is true.
    # 3) A user that does not own the view can create a new copy of
    #    the view just like in #2 except the new view will be owned by
    #    the current user.  This is if @view.owner_id !=
    #    @application_user.id and copy is true.
    allowed = false
    result = false
    if params[:copy] == true || params[:copy] == "true"
      allowed = true
      new_copy = View.new(params[:view])
      new_copy.owner_id = @application_user.id
      # See if we can save the new view
      if (result = new_copy.save)
        # New view is saved, now copy elements from original view to
        # new view.
        @view.elements.each do |element|
          new_element = new_copy.elements.build(element.attributes)
          new_element.owner_id = @application_user.id
          # We ignore the result of the following save.  It should
          # never fail and if it does, we have a new view created and
          # some of the elements didn't get copied but there isn't
          # really a way to convey that to the user.
          new_element.save
        end
        @view = new_copy        # redirect to new copy
      else
        # new_copy has the error messages.  Move them to @view because
        # we want to call edit again with the same record but have the
        # error messages displayed.
        new_copy.errors.each_error do |attr, err|
          @view.errors.add(attr, err)
        end
      end
    elsif @view.owner_id == @application_user.id
      allowed = true
      result = @view.update_attributes(params[:view])
    end
    respond_to do |format|
      if allowed
        if result
          flash[:notice] = 'View was successfully updated.'
          format.html { redirect_to(@view) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @view.errors, :status => :unprocessable_entity }
        end
      else
        @view.errors.add_to_base "You are not the owner of the view so you must make a copy"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @view.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /views/1
  # DELETE /views/1.xml
  def destroy
    @view = View.find(params[:id])
    if @view.owner_id == @application_user.id
      @view.destroy
      respond_to do |format|
        format.html { redirect_to(views_url) }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html { render :file => "public/401.html", :status => :unauthorized }
        format.xml { render :xml => @view.errors, :status => :unauthorized }
      end
    end
  end
end
