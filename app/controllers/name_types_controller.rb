# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
# This controller will be very seldom used but created the full
# scaffold because disk space is cheap.
class NameTypesController < ApplicationController
  layout "configuration"

  # GET /name_types
  # GET /name_types.xml
  def index
    @name_types = NameType.all(:include => :argument_type, :order => "argument_types.position, name_types.name")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @name_types }
    end
  end

  # GET /name_types/1
  # GET /name_types/1.xml
  def show
    @name_type = NameType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @name_type }
    end
  end

  # GET /name_types/new
  # GET /name_types/new.xml
  def new
    @name_type = NameType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @name_type }
    end
  end

  # GET /name_types/1/edit
  def edit
    @name_type = NameType.find(params[:id])
  end

  # POST /name_types
  # POST /name_types.xml
  def create
    @name_type = NameType.new(params[:name_type])

    respond_to do |format|
      if @name_type.save
        flash[:notice] = 'NameType was successfully created.'
        format.html { redirect_to(@name_type) }
        format.xml  { render :xml => @name_type, :status => :created, :location => @name_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @name_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /name_types/1
  # PUT /name_types/1.xml
  def update
    @name_type = NameType.find(params[:id])

    respond_to do |format|
      if @name_type.update_attributes(params[:name_type])
        flash[:notice] = 'NameType was successfully updated.'
        format.html { redirect_to(@name_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @name_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /name_types/1
  # DELETE /name_types/1.xml
  def destroy
    @name_type = NameType.find(params[:id])
    @name_type.destroy

    respond_to do |format|
      format.html { redirect_to(name_types_url) }
      format.xml  { head :ok }
    end
  end
end
