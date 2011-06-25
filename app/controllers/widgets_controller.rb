# -*- coding: utf-8 -*-
class WidgetsController < ApplicationController
  layout "configuration"

  # GET /widgets
  # GET /widgets.xml
  def index
    @widgets = Widget.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @widgets }
    end
  end

  # GET /widgets/1
  # GET /widgets/1.xml
  def show
    @widget = Widget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @widget }
    end
  end

  # GET /widgets/new
  # GET /widgets/new.xml
  def new
    @widget = Widget.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @widget }
    end
  end

  # GET /widgets/1/edit
  def edit
    @widget = Widget.find(params[:id])
  end

  # POST /widgets
  # POST /widgets.xml
  def create
    @widget = Widget.new(params[:widget])
    @widget.owner_id = @application_user.id
    respond_to do |format|
      if @widget.save
        flash[:notice] = 'Widget was successfully created.'
        format.html { redirect_to(@widget) }
        format.xml  { render :xml => @widget, :status => :created, :location => @widget }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @widget.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /widgets/1
  # PUT /widgets/1.xml
  def update
    @widget = Widget.find(params[:id])

    # We want to have three possible outcomes.
    # 1) The change is allowed and it succeeds (allowed == true and
    #    result == true)
    # 2) The change is allowed but it fails (allowed == true and
    #    result != true)
    # 3) The change is not allowed. (allowed != true)

    # What is allowed?
    # 1) A user that owns the widget can change its attributes.  This is
    #    if @widget.owner_id == @application_user.id and copy is false.
    # 2) A user that owns the widget can changes its name and make a
    #    copy (which will cause copies of the elements that belong to
    #    the widget to be created as well)  This is if @widget.owner_id ==
    #    @application_user.id and copy is true.
    # 3) A user that does not own the widget can create a new copy of
    #    the widget just like in #2 except the new widget will be owned by
    #    the current user.  This is if @widget.owner_id !=
    #    @application_user.id and copy is true.
    allowed = false
    result = false
    if params[:copy] == true || params[:copy] == "true"
      allowed = true
      new_copy = Widget.new(params[:widget])
      new_copy.owner_id = @application_user.id
      # See if we can save the new widget
      if !(result = new_copy.save)
        # new_copy has the error messages.  Move them to @widget because
        # we want to call edit again with the same record but have the
        # error messages displayed.
        new_copy.errors.each_error do |attr, err|
          @widget.errors.add(attr, err)
        end
      end
    elsif @widget.owner_id == @application_user.id
      allowed = true
      result = @widget.update_attributes(params[:widget])
    end
    respond_to do |format|
      if allowed
        if result
          flash[:notice] = 'Widget was successfully updated.'
          format.html { redirect_to(@widget) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @widget.errors, :status => :unprocessable_entity }
        end
      else
        @widget.errors.add_to_base "You are not the owner of the widget so you must make a copy"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @widget.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /widgets/1
  # DELETE /widgets/1.xml
  def destroy
    @widget = Widget.find(params[:id])
    if @widget.owner_id == @application_user.id
      @widget.destroy
        respond_to do |format|
        format.html { redirect_to(widgets_url) }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html { render :file => "public/401.html", :status => :unauthorized }
        format.xml { render :xml => @widget.errors, :status => :unauthorized }
      end
    end
  end
end
