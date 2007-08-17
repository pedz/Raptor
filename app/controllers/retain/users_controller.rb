module Retain
  class UsersController < ApplicationController
    before_filter :this_user?, :only => [ :show, :edit, :update, :destroy ]

    # GET /retain/users
    # GET /retain/users.xml
    # Admin user gets the entire list.  Normal user gets a list with
    # only their record
    def index
      if admin?
        @users = RetainUser.find(:all)
      elsif session[:user].retain_user
        @users = [ session[:user].retain_user ]
      else
        @users = []
      end
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @users }
      end
    end

    # GET /retain/users/1
    # GET /retain/users/1.xml
    def show
      # Done in this_user?
      # @user = RetainUser.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @user }
      end
    end

    # GET /retain/users/new
    # GET /retain/users/new.xml
    def new
      return if duplicate?
      @user = RetainUser.new
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @user }
      end
    end

    # GET /retain/users/1/edit
    def edit
      # Done in this_user?
      # @user = RetainUser.find(params[:id])
    end

    # POST /retain/users
    # POST /retain/users.xml
    def create
      return if duplicate?
      @user = RetainUser.new(params[:user])
      respond_to do |format|
        @user.user = session[:user]
        if @user.save
          flash[:notice] = 'RetainUser was successfully created.'
          format.html {
            uri = session[:original_uri]
            session[:original_uri] = nil
            redirect_to(uri || @user)
          }
          format.xml  { render :xml => @user, :status => :created, :location => @user }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /retain/users/1
    # PUT /retain/users/1.xml
    def update
      # Done in this_user?
      # @user = RetainUser.find(params[:id])

      respond_to do |format|
        if @user.update_attributes(params[:user])
          flash[:notice] = 'RetainUser was successfully updated.'
          format.html { redirect_to(@user) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /retain/users/1
    # DELETE /retain/users/1.xml
    def destroy
      # Done in this_user?
      # @user = RetainUser.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html { redirect_to(users_url) }
        format.xml  { head :ok }
      end
    end

    # A user is allowed to have only one retain user record at a time.
    # new and create call this to make sure that the request is not
    # going to produce a second retain user record for this user.
    def duplicate?
      return false if session[:user].user.nil?
      respond_to do |format|
        flash[:error] = "User already has a retain user record.  Please delete before adding"
        format.html { redirect_to(users_url) }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
      return true
    end
    
    # A normal user can only look around at their own record.
    def this_user?
      @user = RetainUser.find(params[:id])
      admin? || @user.user.id == session[:user].id
    end
  end
end
