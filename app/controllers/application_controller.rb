# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
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

  # I don't want this for development because it causes footnotes to
  # be disabled.
  # if Rails.env != "development"
  #   rescue_from Exception, :with => :uncaught_exception
  # end
  rescue_from ActiveRecord::StatementInvalid, :with => :pgerror_handler
  rescue_from 'ActiveLdap::LdapError' do |exception|
    render :text => "<h2 style='text-align: center; color: red;'>LDAP Error: #{exception.message}</h2>"
  end
  
  # Return true if current user is an administrator of the site
  def admin?
    application_user.admin
  end
  helper_method :admin?

  # I'm scared to use "user" so I'm going with "application_user".
  # I keep user_id in the session.
  def application_user
    if @application_user.nil?
      # logger.debug("@application_user is nil")
      # logger.debug("session is #{session.inspect}")
      if session.has_key?(:user_id)
        # logger.debug("session[:user_id] set to #{session[:user_id]}")
        tmp = User.find(:first, :conditions => { :id => session[:user_id]})
        if tmp.nil?
          # logger.debug("Did not find user id #{session[:user_id]}")
          reset_session
        else
          logger.info("Request for #{tmp.ldap_id}")
          @application_user = tmp
        end
      end
    end
    @application_user
  end
  helper_method :application_user

  # A before_filter for the entire application.  This authenticates
  # against bluepages.  If authentication succeeds, the matching user
  # record is found.  If it does not exist, it is created and
  # initialized with the ldap_id field.  The user model is stored in
  # the session.
  def authenticate
    # logger.info("APP: authorization: #{temp_debug(request)}")
    # request.env.keys.each do |key|
    #   logger.debug"request.env['#{key}'] = '#{request.env[key]}'"
    # end
    set_last_uri
    return true unless application_user.nil?
    # logger.info("Header NOT-SET = #{request.headers['NOT-SET'].inspect}")
    if request.env.has_key? "REMOTE_USER"
      # logger.info("REMOTE_USER = #{request.env["REMOTE_USER"]}")
      apache_authenticate
    elsif request.headers.has_key?('HTTP_X_FORWARDED_USER')
      # logger.info("Header HTTP_X_FORWARDED_USER = #{request.headers['HTTP_X_FORWARDED_USER']}")
      proxy_apache_authenticate
    elsif Rails.env == "test"
      # logger.info("Authenticate via test")
      testing_authenticate
    elsif NONE_AUTHENTICATE
      # logger.info("Authenticate via none")
      none_authenticate
    else
      # logger.info("Authenticate else")
      ldap_authenticate
    end
  end

  # A hook that notices if the user goes to the same URI and assumes
  # the user wants to refresh the cache if he does.
  def set_last_uri
    env = request.env
    last_uri = session[:last_uri]
    uri =  env["REQUEST_URI"]
    logger.info("last_uri = #{last_uri}, uri = #{uri}")

    cache_control = request.cache_control
    # logger.debug("APP: cache_control: #{cache_control.inspect}")

    # Note: We look at the cache-control HTTP header.  If it says,
    # 'no-cache', then we do a full refresh.  A "full-refresh" means
    # that we do not trust the state of a queue or the state of a PMR
    # without checking its last modification date.
    if cache_control.is_a? String
      @no_cache = cache_control == "no-cache"
    elsif cache_control.is_a? Array
      @no_cache = cache_control.include?("no-cache")
    else
      @no_cache = false
    end
    # logger.info("APP: no_cache = #{@no_cache}")
    session[:last_uri] = uri
  end

  def fixit(hostname)
    new = hostname.sub(/\..*$/, '')
    # logger.info("Changed hostname from #{hostname} to #{new}")
    return new
  end

  ##
  # Returns the Retuser associated with the current application_user's
  # current_retain_id (the id that the user has choosen to use for
  # this session).  If current_retain_id is not set but there are
  # Retuser entries for this User, then the first one is choosen.
  # This may return nil if no Retuser has been set up for the
  # application User.
  #
  # Note that Retuser has *not* been validated.
  def retain_user
    if application_user.current_retain_id.nil? &&
        (first = application_user.retusers.first)
      application_user.current_retain_id = first
      application_user.save
    end
    @retain_user = application_user.current_retain_id
  end
  helper_method :retain_user

  # Fetches the object -- which is expected to be a subclass of
  # Cached::Base -- asynchronously using the worker tasks.  This can't
  # be a method of the model because it needs to application_user.
  #
  # calls Cached::Base#async_priority to determine the priority of the
  # request.
  #
  # NOTE: This will do nothing if the application_user currently has not 
  def async_fetch(obj, force = false)
    return if retain_user.nil? || (Rails.env == "test")
    return unless obj.respond_to? :async_priority

    pri = obj.async_priority
    return if pri == :none
    logger.debug("async fetch of #{obj} for #{application_user.ldap_id}")
    AsyncRequest.new(retain_user.id, obj).async_send(:fetch, :pri => pri)
  end

  private :fixit
  
  # This authenticates against bluepages using LDAP.
  def ldap_authenticate
    # logger.debug("ldap_authenticate")
    # ldap_time = Benchmark.realtime { ActiveLdap::Base.setup_connection }
    # logger.debug("LDAP: took #{ldap_time} to establish the connection")
    authenticate_or_request_with_http_basic "Bluepages Authentication" do |user_name, password|
      # logger.info("attempt to ldap authenticate: user_name #{user_name}")
      next nil unless LdapUser.authenticate_from_email(user_name, password)
      # logger.info("successful ldap_authenticate as #{user_name}")
      common_authenticate(user_name)
      return true
    end
    return false
  end

  # No authentication although an http basic authentication sequence
  # still occurs
  def none_authenticate
    authenticate_or_request_with_http_basic "Raptor" do |user_name, password|
      # logger.debug("none_authenticate as #{user_name}")
      common_authenticate(user_name)
      return true
    end
    return false
  end

  # Apache has already authenticated so let the user in.
  def apache_authenticate
    # logger.info("apache_authenticate as #{request.env["REMOTE_USER"]}")
    common_authenticate(request.env["REMOTE_USER"])
    return true
  end

  # Apache has already authenticated but we are behind a proxy
  # (e.g. Proxy balancer) so use HTTP_X_FORWARDED_USER instead Note
  # that this header is produced by the httpd config file rules:
  #
  # RewriteCond %{LA-U:REMOTE_USER} (.+)
  # RewriteRule .* - [E=RU:%1]
  # RequestHeader add X-Forwarded-User %{RU}e
  #
  # I believe the reason is the proxy request is sent to the other
  # process (like thin or mongrel) so the environment is not passed.
  # Thus a header has to be introduced.  Somewhere someone picked
  # X-Forwarded-User.  Rails takes all incoming headers and stores
  # them in headers as
  # "HTTP_" original_header_name.upcase.gsub(/-/, '_').  See
  # actionpack/lib/action_dispatch/http/headers.rb
  def proxy_apache_authenticate
    # logger.info("proxy_apache_authenticate as #{request.env["HTTP_X_FORWARDED_USER"]}")
    common_authenticate(request.headers["HTTP_X_FORWARDED_USER"])
    return true
  end

  def testing_authenticate
    # logger.info("testing_authenticate")
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
      user = User.new
      user.ldap_id = user_name
      user.save!
    end
    session[:user_id] = user.id
  end
  
  def temp_debug(request)
    request.env['HTTP_AUTHORIZATION']   ||
      request.env['X-HTTP_AUTHORIZATION'] ||
      request.env['X_HTTP_AUTHORIZATION'] ||
      request.env['REDIRECT_X_HTTP_AUTHORIZATION']
  end

  
  # A normal user can only look around at their own record.
  def check_user(user_id)
    begin
      @user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      unless admin?
        render :file => "public/404.html", :status => 404, :layout => false
        return
      else
        @user = nil
      end
    end
    
    logger.debug("hi 5")
    if @user.nil? || !(admin? || @user.id == session[:user_id])
      flash[:notice] = "Must use your own id"
      redirect_to(:controller => "welcome", :action => "index", :status => 403)
    end
  end

  def admin_only
    unless admin?
      flash[:notice] = "Not Permitted"
      redirect_to(:controller => "welcome", :action => "index", :status => 403)
    end
  end

  protected

  def set_expires_now
    expires_now
    headers.delete('ETag')
    headers.delete('Last-Modified')
  end

  private

  def pgerror_handler(exception)
    set_expires_now
    @exception = exception
    msg = exception.message
    logger.error(exception.to_s)
    logger.error(exception.backtrace.join("\n"))
    if msg.match(/duplicate key .*violates unique constraint/)
      render "pgerrors/duplicate_key.html", :layout => "pgerrors"
      return
    end
    if msg.match(/violates not-null constraint/)
      render "pgerrors/not_null.html", :layout => "pgerrors"
      return
    end
    render "pgerrors/unknown.html", :layout => "pgerrors"
  end

  def uncaught_exception(exception)
    set_expires_now
    raise exception
  end
end
