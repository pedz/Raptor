module Retain
  class RetainController < ApplicationController
    
    before_filter :validate_retuser
    
    rescue_from Retain::LogonFailed, :with => :logon_failed
    rescue_from Retain::FailedMarkedTrue, :with => :failed_marked_true
    # rescue_from ActionView::TemplateError, :with => :my_template_error

    private
    
    #
    # A before filter for the retain part of the application.  Any
    # controller that might call in to retain should be subclassed as
    # a RetainController.
    #
    def validate_retuser
      logger.debug("RTN: in validate_retuser")
      user = session[:user]
      
      # Avoid extra db hits if session[:retain] already set
      if params = session[:retain]
        logger.debug("RTN: setting logon params #{__LINE__}")
        Logon.instance.set(params)
        return true
      end
      
      # If no retusers defined for this user, then redirect and
      # set up a retain user.
      if user.retusers.empty?
        session[:original_uri] = request.request_uri
        redirect_to new_retuser_url
        return false
      end

      setup_logon_instance
      return true
    end

    # Pull together the signon/password and the host/port and create a
    # ConnectionParamters structure.  We hold this in the session
    # data.  We also set the Logon instance to use these settings.
    def setup_logon_instance
      retuser = session[:user].retusers[0]
      config = Retain::Config.symbolize_keys[RetainConfig::Node][0].symbolize_keys
      params = ConnectionParameters.new(:host     => config[:host],
                                        :port     => config[:port],
                                        :signon   => retuser.retid,
                                        :password => retuser.password,
                                        :failed   => retuser.failed)
      session[:retain] = params
      Logon.instance.set(params)
    end
    
    def logon_failed
      # Find the retuser record and set the failed bit to true so we
      # do not retry until the user resets his password.
      user = session[:user]
      retuser = user.retusers[0]
      retuser.failed = true
      retuser.save

      flash[:error] = "Login failed -- bad password?"
      # Remember what we were trying to do
      session[:original_uri] = request.request_uri
      # Go edit the retuser
      redirect_to edit_retuser_url(retuser)
    end

    def failed_marked_true
      flash[:warning] = "'failed' flag set.  Check password, clear 'failed' flag, and try again"

      # Remember what we were trying to do
      session[:original_uri] = request.request_uri

      # Go edit the retuser
      user = session[:user]
      retuser = user.retusers[0]
      redirect_to edit_retuser_url(retuser)
    end
  end
end
