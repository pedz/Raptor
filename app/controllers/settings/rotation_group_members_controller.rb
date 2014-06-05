# -*- coding: utf-8 -*-
#
# Copyright 2007-2014 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Settings
  class RotationGroupMembersController < ApplicationController
    before_filter :get_rotation_group
    layout "settings"

    # GET /rotation_group_members
    # GET /rotation_group_members.xml
    def index
      @rotation_group_members = @rotation_group.active_group_members
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @rotation_group_members }
      end
    end
    
    # GET /rotation_group_members/1
    # GET /rotation_group_members/1.xml
    def show
      @rotation_group_member = @rotation_group.rotation_group_members.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @rotation_group_member }
      end
    end
    
    # GET /rotation_group_members/new
    # GET /rotation_group_members/new.xml
    def new
      @rotation_group_member = @rotation_group.rotation_group_members.build
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @rotation_group_member }
      end
    end
    
    # GET /rotation_group_members/1/edit
    def edit
      @rotation_group_member = @rotation_group.rotation_group_members.find(params[:id])
    end
    
    # POST /rotation_group_members
    # POST /rotation_group_members.xml
    def create
      @rotation_group_member = @rotation_group.rotation_group_members.build(params[:rotation_group_member])
      
      respond_to do |format|
        if @rotation_group_member.save
          format.html { redirect_to(settings_rotation_group_rotation_group_member_path(@rotation_group, @rotation_group_member),
                                    :notice => 'RotationGroupMember was successfully created.') }
          format.xml  { render :xml => @rotation_group_member, :status => :created, :location => @rotation_group_member }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @rotation_group_member.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /rotation_group_members/1
    # PUT /rotation_group_members/1.xml
    def update
      @rotation_group_member = @rotation_group.rotation_group_members.find(params[:id])
      
      respond_to do |format|
        if @rotation_group_member.update_attributes(params[:rotation_group_member])
          format.html { redirect_to(settings_rotation_group_rotation_group_member_path(@rotation_group, @rotation_group_member),
                                    :notice => 'RotationGroupMember was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @rotation_group_member.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /rotation_group_members/1
    # DELETE /rotation_group_members/1.xml
    def destroy
      @rotation_group_member = @rotation_group.rotation_group_members.find(params[:id])
      @rotation_group_member.destroy
      
      respond_to do |format|
        format.html { redirect_to(settings_rotation_group_rotation_group_members_url(@rotation_group)) }
        format.xml  { head :ok }
      end
    end

    private

    def get_rotation_group
      @rotation_group = RotationGroup.find(params[:rotation_group_id])
    end
  end
end
