class RetainUsersController < ApplicationController
  before_filter :admin? :except => [ :new ]
  before_filter :this_user

  # GET /retain_users
  # GET /retain_users.xml
  def index
    @retain_users = RetainUser.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @retain_users }
    end
  end

  # GET /retain_users/1
  # GET /retain_users/1.xml
  def show
    @retain_user = RetainUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retain_user }
    end
  end

  # GET /retain_users/new
  # GET /retain_users/new.xml
  def new
    @retain_user = RetainUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retain_user }
    end
  end

  # GET /retain_users/1/edit
  def edit
    @retain_user = RetainUser.find(params[:id])
  end

  # POST /retain_users
  # POST /retain_users.xml
  def create
    @retain_user = RetainUser.new(params[:retain_user])
    @retain_user.user = session[:user]
    respond_to do |format|
      if @retain_user.save
        flash[:notice] = 'RetainUser was successfully created.'
        format.html {
          uri = session[:original_uri]
          session[:original_uri] = nil
          redirect_to(uri || @retain_user)
        }
        format.xml  { render :xml => @retain_user, :status => :created, :location => @retain_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retain_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retain_users/1
  # PUT /retain_users/1.xml
  def update
    @retain_user = RetainUser.find(params[:id])

    respond_to do |format|
      if @retain_user.update_attributes(params[:retain_user])
        flash[:notice] = 'RetainUser was successfully updated.'
        format.html { redirect_to(@retain_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @retain_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retain_users/1
  # DELETE /retain_users/1.xml
  def destroy
    @retain_user = RetainUser.find(params[:id])
    @retain_user.destroy

    respond_to do |format|
      format.html { redirect_to(retain_users_url) }
      format.xml  { head :ok }
    end
  end
end
