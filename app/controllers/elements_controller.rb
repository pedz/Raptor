# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class ElementsController < ApplicationController
  before_filter :get_view
  before_filter :check_view, :except => [ :index, :show ]
  layout "configuration"

  # GET /views/1/elements
  # GET /views/1/elements.xml
  def index
    @elements = @view.elements.all(:order => "row ASC, col ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @elements }
    end
  end

  # GET /elements/1
  # GET /elements/1.xml
  def show
    @element = @view.elements.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @element }
    end
  end

  # GET /elements/new
  # GET /elements/new.xml
  def new
    @element = @view.elements.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @element }
    end
  end

  # GET /elements/1/edit
  def edit
    @element = @view.elements.find(params[:id])
  end

  # POST /elements
  # POST /elements.xml
  def create
    @element = @view.elements.build(params[:element])
    @element.owner_id = @application_user.id

    respond_to do |format|
      if @element.save
        flash[:notice] = 'Element was successfully created.'
        format.html { redirect_to view_element_path(@view, @element) }
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
    @element = @view.elements.find(params[:id])

    respond_to do |format|
      if @element.update_attributes(params[:element])
        flash[:notice] = 'Element was successfully updated.'
        format.html { redirect_to view_element_path(@view, @element) }
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
    @element = @view.elements.find(params[:id])
    @element.destroy

    respond_to do |format|
      format.html { redirect_to(view_elements_url(@view)) }
      format.xml  { head :ok }
    end
  end

  private

  def get_view
    @view = View.find(params[:view_id])
  end

  def check_view
    if @view.owner_id != @application_user.id
      flash[:error] = "Only owner of view can modify its elements"
      redirect_to(view_elements_url(@view))
    end
  end
end
