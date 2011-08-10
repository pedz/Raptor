# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Settings
  class UsersController < ApplicationController
    before_filter :admin_only, :only => [ :destroy, :new ]
    before_filter :this_user?, :except => [ :index, :new ]
    
    # GET /users
    # GET /users.xml
    # Admin user gets the entire list.  Normal user gets a list with
    # only their record.  Much like RetainUsersController.  In this
    # case, we know we have a user so record because the validation
    # sequence assures us that.
    def index
      if admin?
        @users = User.find(:all)
      else
        @users = [ application_user ]
      end
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @users }
      end
    end
    
    # GET /users/1
    # GET /users/1.xml
    def show
      # This is done in this_user?
      # @user = User.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @user }
      end
    end
    
    # GET /users/new
    # GET /users/new.xml
    # This will likely be a waste of time but -- go ahead and try it.
    def new
      @user = User.new
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @user }
      end
    end
    
    # GET /users/1/edit
    def edit
      # This is done in this_user?
      # @user = User.find(params[:id])
    end
    
    # POST /users
    # POST /users.xml
    # This could probably be deleted.  None of the needed attributes
    # will be set at the new because they are protected.  So the save is
    # going to fail.  But, for now, lets keep it here.
    def create
      @user = User.new(params[:user])
      
      respond_to do |format|
        if @user.save
          flash[:notice] = 'User was successfully created.'
          format.html { redirect_to(@user) }
          format.xml  { render :xml => @user, :status => :created, :location => @user }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /users/1
    # PUT /users/1.xml
    # Some arguments might get saved here.  We also make a special check
    # for the admin flag and set it if it is set in params and the
    # current user is an admin.
    def update
      # Done by this_user?
      # @user = User.find(params[:id])
      # currently a no-op 'cause everything is protected
      @user.attributes = params[:user]
      
      admin_param = params[:user].delete(:admin)
      if admin?
        @user.admin = admin_param unless admin_param.nil?
      end
      
      respond_to do |format|
        if @user.save
          flash[:notice] = 'User was successfully updated.'
          format.html { redirect_to(@user) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /users/1
    # DELETE /users/1.xml
    def destroy
      # Done in this_user?
      # @user = User.find(params[:id])
      @user.destroy
      
      respond_to do |format|
        format.html { redirect_to(users_url) }
        format.xml  { head :ok }
      end
    end
    
    private
    
    # Stolen code from retain_users_controller.  I can't think of why
    # this would ever return false (when would the create or new not be
    # a duplicate?
    def duplicate?
      # return false if ????
      respond_to do |format|
        flash[:error] = "User already has a user record."
        format.html { redirect_to(users_url) }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
      return true
    end
    
    private
    
    def this_user?
      check_user(params[:id])
    end
  end
end
