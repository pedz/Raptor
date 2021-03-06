# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class RelationshipTypesController < ApplicationController
  layout "configuration"

  # GET /relationship_types
  # GET /relationship_types.xml
  def index
    @relationship_types = RelationshipType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @relationship_types }
    end
  end

  # GET /relationship_types/1
  # GET /relationship_types/1.xml
  def show
    @relationship_type = RelationshipType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @relationship_type }
    end
  end

  # GET /relationship_types/new
  # GET /relationship_types/new.xml
  def new
    @relationship_type = RelationshipType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @relationship_type }
    end
  end

  # GET /relationship_types/1/edit
  def edit
    @relationship_type = RelationshipType.find(params[:id])
  end

  # POST /relationship_types
  # POST /relationship_types.xml
  def create
    @relationship_type = RelationshipType.new(params[:relationship_type])

    respond_to do |format|
      if @relationship_type.save
        flash[:notice] = 'RelationshipType was successfully created.'
        format.html { redirect_to(@relationship_type) }
        format.xml  { render :xml => @relationship_type, :status => :created, :location => @relationship_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /relationship_types/1
  # PUT /relationship_types/1.xml
  def update
    @relationship_type = RelationshipType.find(params[:id])

    respond_to do |format|
      if @relationship_type.update_attributes(params[:relationship_type])
        flash[:notice] = 'RelationshipType was successfully updated.'
        format.html { redirect_to(@relationship_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /relationship_types/1
  # DELETE /relationship_types/1.xml
  def destroy
    @relationship_type = RelationshipType.find(params[:id])
    @relationship_type.destroy

    respond_to do |format|
      format.html { redirect_to(relationship_types_url) }
      format.xml  { head :ok }
    end
  end
end
