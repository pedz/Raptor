# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8910e3b53f5d90250401a50d7db1750b'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  unless defined?(HERE)
    before_filter :authenticate 
    HERE = 1
  end
  
  # For development mode, we do not do the authentication with
  # Bluepages
  unless defined? NONE_AUTHENTICATE
    NONE_AUTHENTICATE = File.exists?(RAILS_ROOT + "/config/no_ldap")
  end

  rescue_from 'ActiveLdap::LdapError' do |exception|
    render :text => "<h2 style='text-align: center; color: red;'>LDAP Error: #{exception.message}</h2>"
  end
  
  # Return true if current user is an administrator of the site
  def admin?
    application_user.admin
  end

  # I'm scared to use "user" so I'm going with "application_user".
  # I keep user_id in the session.
  def application_user
    unless @application_user.nil?
      if session.has_key?(:user_id)
        tmp = User.find(:first, :id => session[:user_id])
        if tmp.nil?
          reset_session
        else
          @application_user = tmp
        end
      end
    end
    @application_user
  end

  # A before_filter for the entire application.  This authenticates
  # against bluepages.  If authentication succeeds, the matching user
  # record is found.  If it does not exist, it is created and
  # initialized with the ldap_id field.  The user model is stored in
  # the session.
  def authenticate
    set_last_uri
    return true unless application_user.nil?
    if request.env.has_key? "REMOTE_USER"
      apache_authenticate
    elsif Rails.env == "staging"
      staging_authenticate
    elsif NONE_AUTHENTICATE
      none_authenticate
    else
      ldap_authenticate
    end
  end

  # A hook that notices if the user goes to the same URI and assumes
  # the user wants to refresh the cache if he does.
  def set_last_uri
    last_uri = session[:last_uri]
    logger.debug("REMOTE_USER = #{request.env["REMOTE_USER"]}")
    uri =  request.env["REQUEST_URI"]
    logger.debug("last_uri = #{last_uri}, uri = #{uri}")
    if last_uri == uri
      flash[:notice] = "Fully Refreshed"
      @refresh_time = Time.now
      logger.debug("doing a refresh")
    else
      flash.delete :notice
      @refresh_time = nil
      logger.debug("not refreshing")
    end
    session[:last_uri] = uri
  end

  # This authenticates against bluepages using LDAP.
  def ldap_authenticate
    logger.debug("ldap_authenticate")
    ldap_time = Benchmark.realtime { ActiveLdap::Base.establish_connection }
    logger.debug("LDAP: took #{ldap_time} to establish the connection")
    authenticate_or_request_with_http_basic "Bluepages Authentication" do |user_name, password|
      logger.debug("TEMP: user_name #{user_name} password #{password}")
      next nil unless LdapUser.authenticate_from_email(user_name, password)
      common_authenticate(user_name)
      return true
    end
    return false
  end

  # No authentication although an http basic authentication sequence
  # still occurs
  def none_authenticate
    logger.debug("none_authenticate")
    authenticate_or_request_with_http_basic "Raptor" do |user_name, password|
      common_authenticate(user_name)
      return true
    end
    return false
  end

  # Apache has already authenticated so let the user in.
  def apache_authenticate
    logger.debug("apache_authenticate")
    common_authenticate(request.env["REMOTE_USER"])
    return true
  end

  def staging_authenticate
    logger.debug("staging_authenticate")
    common_authenticate('pedzan@us.ibm.com')
    return true
  end

  # Common set up steps in the authentication process After
  # authentication succeeds, the matching user record is found.  If it
  # does not exist, it is created and initialized with the ldap_id
  # field.  The user model is stored in the session.
  def common_authenticate(user_name)
    user = User.find_by_ldap_id(user_name)
    if user.nil?
      # Can not use this because ldap_id is protected
      # User.create!(:ldap_id => user_name)
      # Use this instead:
      user = User.new
      user.ldap_id = user_name
      user.save!
    end
    session[:user_id] = user.id
  end
end
