# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Settings
  class RotationGroupsController < ApplicationController
    # GET /rotation_groups
    # GET /rotation_groups.xml
    def index
      @rotation_groups = RotationGroup.all
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @rotation_groups }
      end
    end
    
    # GET /rotation_groups/1
    # GET /rotation_groups/1.xml
    def show
      @rotation_group = RotationGroup.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @rotation_group }
      end
    end
    
    # GET /rotation_groups/new
    # GET /rotation_groups/new.xml
    def new
      @rotation_group = RotationGroup.new
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @rotation_group }
      end
    end
    
    # GET /rotation_groups/1/edit
    def edit
      @rotation_group = RotationGroup.find(params[:id])
    end
    
    # POST /rotation_groups
    # POST /rotation_groups.xml
    def create
      @rotation_group = RotationGroup.new(params[:rotation_group])
      
      respond_to do |format|
        if @rotation_group.save
          format.html { redirect_to([:settings, @rotation_group], :notice => 'RotationGroup was successfully created.') }
          format.xml  { render :xml => @rotation_group, :status => :created, :location => @rotation_group }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @rotation_group.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /rotation_groups/1
    # PUT /rotation_groups/1.xml
    def update
      @rotation_group = RotationGroup.find(params[:id])
      
      respond_to do |format|
        if @rotation_group.update_attributes(params[:rotation_group])
          format.html { redirect_to(@rotation_group, :notice => 'RotationGroup was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @rotation_group.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /rotation_groups/1
    # DELETE /rotation_groups/1.xml
    def destroy
      @rotation_group = RotationGroup.find(params[:id])
      @rotation_group.destroy
      
      respond_to do |format|
        format.html { redirect_to(rotation_groups_url) }
        format.xml  { head :ok }
      end
    end
  end
end
