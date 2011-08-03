# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class AssociationTypesController < ApplicationController
  layout "configuration"

  # GET /association_types
  # GET /association_types.xml
  def index
    @association_types = AssociationType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @association_types }
    end
  end

  # GET /association_types/1
  # GET /association_types/1.xml
  def show
    @association_type = AssociationType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @association_type }
    end
  end

  # GET /association_types/new
  # GET /association_types/new.xml
  def new
    @association_type = AssociationType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @association_type }
    end
  end

  # GET /association_types/1/edit
  def edit
    @association_type = AssociationType.find(params[:id])
  end

  # POST /association_types
  # POST /association_types.xml
  def create
    @association_type = AssociationType.new(params[:association_type])

    respond_to do |format|
      if @association_type.save
        flash[:notice] = 'AssociationType was successfully created.'
        format.html { redirect_to(@association_type) }
        format.xml  { render :xml => @association_type, :status => :created, :location => @association_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @association_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /association_types/1
  # PUT /association_types/1.xml
  def update
    @association_type = AssociationType.find(params[:id])

    respond_to do |format|
      if @association_type.update_attributes(params[:association_type])
        flash[:notice] = 'AssociationType was successfully updated.'
        format.html { redirect_to(@association_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @association_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /association_types/1
  # DELETE /association_types/1.xml
  def destroy
    @association_type = AssociationType.find(params[:id])
    @association_type.destroy

    respond_to do |format|
      format.html { redirect_to(association_types_url) }
      format.xml  { head :ok }
    end
  end
end
