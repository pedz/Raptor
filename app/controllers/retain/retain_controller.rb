module Retain
  class RetainController < ApplicationController
    
    before_filter :validate_retuser
    cache_sweeper :pmr_sweeper, :call_sweeper
    
    rescue_from Retain::LogonFailed, :with => :logon_failed
    rescue_from Retain::FailedMarkedTrue, :with => :failed_marked_true 
    rescue_from Retain::SdiReaderError do |exception|
      # logger.debug("SDI Exception Stack")
      # logger.debug("#{exception.backtrace.join("\n")}")
      render :text => <<-End
        <h2 style='text-align: center; color: red;'>Retain SDI Error<br/>
            #{exception.message}<br/>
            Return Code #{exception.rc}
        </h2>
        <p>
          This may be due to a transient Retain problem or it may be a
  real programming error.  Try the same thing a few times and if the
  problem persists or if you can find a reproducable error, please let
  Perry know.
        </p>
      End
    end

    def signon_user
      @signon_user ||=
        Combined::Registration.find_or_initialize_by_signon(Retain::Logon.instance.signon)
    end
    helper_method :signon_user

    private
    
    def perform_action_with_retain_benchmark
      Retain::Connection.reset_time
      # logger.debug("perform_action_with_retain_benchmark: self is #{self}")
      perform_action_without_retain_benchmark
      calls = Retain::Connection.request_count
      time = Retain::Connection.total_time
      avg = time / [ calls, 1 ].max
      logger.info("perform_action_with_retain_benchmark: #{calls} calls, #{time} time, #{avg} average")
    end
    alias_method_chain :perform_action, :retain_benchmark

    #
    # A before filter for the retain part of the application.  Any
    # controller that might call in to retain should be subclassed as
    # a RetainController.
    #
    def validate_retuser
      # logger.debug("RTN: in validate_retuser")
      
      # If no retusers defined for this user, then redirect and
      # set up a retain user.
      if application_user.retusers.empty?
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
      retuser = application_user.retusers[0]
      config = Retain::Config.symbolize_keys[RetainConfig::Node][0].symbolize_keys
      params = ConnectionParameters.new(:host     => config[:host],
                                        :port     => config[:port],
                                        :signon   => retuser.retid,
                                        :password => retuser.password,
                                        :failed   => retuser.failed)
      Logon.instance.set(params)
    end
    
    def logon_failed
      # logger.debug("logon failed")
      # Find the retuser record and set the failed bit to true so we
      # do not retry until the user resets his password.
      retuser = application_user.retusers[0]
      retuser.failed = true
      retuser.save

      flash[:error] = "Login failed -- bad password?"
      # Remember what we were trying to do
      session[:original_uri] = request.request_uri
      # Go edit the retuser
      redirect_to edit_retuser_url(retuser)
    end

    def failed_marked_true
      # logger.debug("failed marked true")
      flash[:warning] = "'failed' flag set.  Check password, clear 'failed' flag, and try again"

      # Remember what we were trying to do
      session[:original_uri] = request.request_uri

      # Go edit the retuser
      retuser = application_user.retusers[0]
      redirect_to edit_retuser_url(retuser)
    end
  end
end
