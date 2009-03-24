class RetusersController < ApplicationController
  before_filter :this_user?, :only => [ :show, :edit, :update, :destroy ]
  
  # GET /retain/users
  # GET /retain/users.xml
  # Admin user gets the entire list.  Normal user gets a list with
  # only their record
  def index
    if admin?
      @retusers = Retuser.find(:all)
    else
      @retusers = application_user.retusers
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @retusers }
    end
  end
  
  # GET /retain/users/1
  # GET /retain/users/1.xml
  def show
    # Done in this_user?
    # @retuser = Retuser.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retuser }
    end
  end
  
  # GET /retain/users/new
  # GET /retain/users/new.xml
  def new
    return if duplicate?
    @retuser = Retuser.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retuser }
    end
  end
  
  # GET /retain/users/1/edit
  def edit
    # Done in this_user?
    # @retuser = Retuser.find(params[:id])
  end
  
  # POST /retain/users
  # POST /retain/users.xml
  def create
    return if duplicate?
    @retuser = Retuser.new(params[:retuser])
    respond_to do |format|
      @retuser.user = application_user
      if @retuser.save
        flash[:notice] = 'Retuser was successfully created.'
        format.html {
          uri = session[:original_uri]
          session[:original_uri] = nil
          redirect_to(uri || @retuser)
        }
        format.xml  { render :xml => @retuser, :status => :created, :location => @retuser }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retuser.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /retain/users/1
  # PUT /retain/users/1.xml
  def update
    # Done in this_user?
    # @retuser = Retuser.find(params[:id])
    
    respond_to do |format|
      if @retuser.update_attributes(params[:retuser])
        flash[:notice] = 'Retuser was successfully updated.'
        format.html {
          uri = session[:original_uri]
          session[:original_uri] = nil
          redirect_to(uri || @retuser)
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @retuser.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /retain/users/1
  # DELETE /retain/users/1.xml
  def destroy
    # Done in this_user?
    # @retuser = Retuser.find(params[:id])
    @retuser.destroy
    
    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
  # A user is allowed to have only one retain user record at a time.
  # new and create call this to make sure that the request is not
  # going to produce a second retain user record for this user.
  def duplicate?
    return false if application_user.retusers.length == 0
    respond_to do |format|
      flash[:error] = "User already has a retain user record.  Please delete before adding"
      format.html { redirect_to(users_url) }
      format.xml  { render :xml => @retuser.errors, :status => :unprocessable_entity }
    end
    return true
  end
  
  # A normal user can only look around at their own record.
  def this_user?
    @retuser = Retuser.find_by_retid(params[:id])
    admin? || @retuser.user_id == session[:user_id]
  end
end
