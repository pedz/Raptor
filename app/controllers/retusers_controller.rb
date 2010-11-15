# -*- coding: utf-8 -*-

class RetusersController < ApplicationController
  before_filter :this_user?
  before_filter :this_retuser?, :except => [ :index, :new, :create ]
  
  # GET /users/1/retusers
  # GET /users/1/retusers.xml
  def index
    @retusers = @user.retusers
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @retusers }
    end
  end
  
  # GET /users/1/retusers/2
  # GET /users/1/retusers/2
  def show
    # @retuser set in this_retuser?
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retuser }
    end
  end
  
  # GET /users/1/retusers/new
  # GET /users/1/retusers/new.xml
  def new
    @retuser = @user.retusers.build
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retuser }
    end
  end
  
  # GET /users/1/retusers/2/edit
  def edit
    # @retuser set in this_retuser?
  end
  
  # POST /users/1/retuser
  # POST /users/1/retuser.xml
  def create
    @retuser = Retuser.new(params[:retuser])
    # Change the retain node selectors to the defalt test nodes if
    # apptest is set.
    if @retuser.apptest
      @retuser.software_node =
        RetainNodeSelector.find(:first,
                                :joins => [ :retain_node ],
                                :conditions => {
                                  "retain_nodes.apptest" => true,
                                  "retain_nodes.node_type" => "software"
                                })
      @retuser.hardware_node =
        RetainNodeSelector.find(:first,
                                :joins => [ :retain_node ],
                                :conditions => {
                                  "retain_nodes.apptest" => true,
                                  "retain_nodes.node_type" => "hardware"
                                })
    end

    respond_to do |format|
      if (@user.retusers << @retuser)
        flash[:notice] = 'Retuser was successfully created.'
        @user.current_retain_id = @retuser
        @user.save!
        format.html {
          uri = session[:original_uri]
          session[:original_uri] = nil
          redirect_to(uri || user_retuser_url(@user, @retuser))
        }
        format.xml  { render :xml => @retuser, :status => :created, :location => @retuser }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retuser.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /users/1/retuser
  # PUT /users/1/retuser.xml
  def update
    # @retuser set in this_retuser?
    
    respond_to do |format|
      if @retuser.update_attributes(params[:retuser])
        flash[:notice] = 'Retuser was successfully updated.'
        format.html {
          uri = session[:original_uri]
          session[:original_uri] = nil
          redirect_to(uri || user_retuser_url(@user))
        }
        format.xml  { head :ok }
      else
        format.html { render(:action => :edit) }
        format.xml  { render :xml => @retuser.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /users/1/retuser
  # DELETE /users/1/retuser.xml
  def destroy
    # @retuser set in this_retuser?
    @retuser.destroy
    
    respond_to do |format|
      format.html { redirect_to(user_retusers_url(@user)) }
      format.xml  { head :ok }
    end
  end
  
  private

  def this_user?
    check_user(params[:user_id])
  end

  def this_retuser?
    return true if (@retuser = @user.retusers.find(params[:id]))
    flash[:error] = "Retuser #{params[:id]} not found for this user"
    redirect_to(:action => "index")
  end
end
