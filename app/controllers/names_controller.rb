# -*- coding: utf-8 -*-
# This controller will be used only for maintenance purposes.  There
# are several models that inherit using "Single Table Inheritance"
# from the names table.  Those controllers will be for general use.
class NamesController < ApplicationController
  layout "configuration"

  # GET /names
  # GET /names.xml
  def index
    @names = Name.all(:order => "type, name")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @names }
    end
  end

  # GET /names/1
  # GET /names/1.xml
  def show
    @name = Name.find(params[:id]).becomes(Name)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @name }
    end
  end

  # GET /names/new
  # GET /names/new.xml
  def new
    @name = Name.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @name }
    end
  end

  # GET /names/1/edit
  def edit
    @name = Name.find(params[:id]).becomes(Name)
  end

  # POST /names
  # POST /names.xml
  def create
    p = params[:name]
    # Is this how I want to do this?
    type = p.delete(:type)
    @name = Name.new(p)
    @name.type = type
    @name.owner = application_user
    respond_to do |format|
      if @name.save
        flash[:notice] = 'Name was successfully created.'
        format.html { redirect_to(@name) }
        format.xml  { render :xml => @name, :status => :created, :location => @name }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @name.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /names/1
  # PUT /names/1.xml
  def update
    @name = Name.find(params[:id]).becomes(Name)

    respond_to do |format|
      if @name.update_attributes(params[:name])
        flash[:notice] = 'Name was successfully updated.'
        format.html { redirect_to(@name) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @name.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /names/1
  # DELETE /names/1.xml
  def destroy
    @name = Name.find(params[:id]).becomes(Name)
    @name.destroy

    respond_to do |format|
      format.html { redirect_to(names_url) }
      format.xml  { head :ok }
    end
  end
end
