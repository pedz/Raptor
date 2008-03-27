# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  before_filter :authenticate

  rescue_from 'ActiveLdap::LdapError' do |exception|
    render :text => "<h2 style='text-align: center; color: red;'>LDAP Error: #{exception.message}</h2>"
  end
  
  def admin?
    session[:user].admin
  end

  private
  
  #
  # A before_filter for the entire application.  This authenticates
  # against bluepages.  If authentication succeeds, the matching user
  # record is found.  If it does not exist, it is created and
  # initialized with the ldap_id field.  The user model is stored in
  # the session.
  #
  def authenticate
    last_uri = session[:last_uri]
    uri =  request.env["REQUEST_URI"]
    logger.debug("last_uri = #{last_uri}, uri = #{uri}")
    if last_uri == uri
      flash[:notice] = "Fully Refreshed"
      @refresh_time = Time.now
      logger.debug("doing a refresh")
    else
      @refresh_time = nil
      logger.debug("not refreshing")
    end
    session[:last_uri] = uri
    
    return true if session[:user]
    ActiveLdap::Base.establish_connection
    authenticate_or_request_with_http_basic "Raptor" do |user_name, password|
      next nil unless LdapUser.authenticate_from_email(user_name, password)
      user = User.find_by_ldap_id(user_name)
      if user.nil?
        # Can not use this because ldap_id is protected
        # User.create!(:ldap_id => user_name)
        # Use this instead:
        user = User.new
        user.ldap_id = user_name
        user.save!
      end
      session[:user] = user
      session[:retain] = nil
      return true
    end
    return false
  end
end
