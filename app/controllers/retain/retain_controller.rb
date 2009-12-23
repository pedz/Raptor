# -*- coding: utf-8 -*-

module Retain
  class RetainController < ApplicationController
    
    before_filter :validate_retuser
    cache_sweeper :pmr_sweeper, :call_sweeper
    
    rescue_from Combined::CallNotFound,     :with => :not_found_page
    rescue_from Combined::CenterNotFound,   :with => :not_found_page
    rescue_from Combined::PmrNotFound,      :with => :not_found_page
    rescue_from Combined::QueueNotFound,    :with => :not_found_page
    rescue_from Retain::FailedMarkedTrue,   :with => :failed_marked_true
    rescue_from Retain::LogonFailed,        :with => :logon_failed
    rescue_from Retain::SdiReaderError,     :with => :sdi_error_page
    rescue_from Retain::RetainLogonEmpty,   :with => :retain_logon_empty
    rescue_from Retain::RetainLogonShort,   :with => :retain_logon_short
    rescue_from Retain::SdiDidNotReadField, :with => :retain_did_not_read_field
    
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
      params = ConnectionParameters.new(:signon   => retuser.retid,
                                        :password => retuser.password,
                                        :failed   => retuser.failed)
      Logon.instance.set(params)
    end
    
    def logon_failed(exception)
      # logger.debug("logon failed")
      # Find the retuser record and set the failed bit to true so we
      # do not retry until the user resets his password.
      retuser = application_user.retusers[0]
      retuser.failed = true
      retuser.return_value = Logon.instance.return_value
      retuser.reason = Logon.instance.reason
      retuser.save

      flash[:error] = find_logon_error(retuser.return_value, retuser.reason)
      common_failed_logon(retuser)
    end

    def failed_marked_true(exception)
      retuser = application_user.retusers[0]
      flash[:warning] = find_logon_error(retuser.return_value, retuser.reason)
      common_failed_logon(retuser)
    end

    def common_failed_logon(retuser)
      # Remember what we were trying to do
      session[:original_uri] = request.request_uri
      redirect_to edit_retuser_url(retuser)
    end

    #        16 |     18 |      Fail | Retain database not available for userid
    #           |        |           |   validation
    #        70 |     19 |      Fail | Userid is set to inactive
    #        70 |     20 |      Fail | Userid is being blocked due to
    #           |        |           |   excessive errors
    #        70 |     21 |      Fail | Client IP address being blocked
    #           |        |           |   due to excessive errors
    #        70 |     22 |      Fail | Client IP address blocked for
    #           |        |           |   other error
    #        70 |      2 |      Fail | Password does not match current
    #           |        |           |   database password
    #        70 |      3 | Cond Pass | Password has expired, only
    #           |        |           |   a PMDR change password
    #           |        |           |   permitted
    #        69 |      8 |      Fail | Invalid/Unknown Retain userid
    #         8 |     16 |      Fail | Invalid Eyecatch "SDIRETEX"
    #         8 |     12 |      Fail | Userid blank
    #         8 |      8 |      Fail | Password blank
    #         4 |      n |      Pass | Userid/Password validated,
    #           |        |           |   password will expire in n (1 to
    #           |        |           |   7) days
    #         0 |      n |      Pass | Userid/Password validated,
    #           |        |           |   password will expire in n (8 to
    #           |        |           |   90) days
    def find_logon_error(return_value, reason)
      return "Retain database not available for userid validation" if return_value == 16 && reason == 18
      return "Userid is set to inactive" if return_value == 70 && reason == 19
      return "Userid is being blocked due to excessive errors" if return_value == 70 && reason == 20
      return "Client IP address being blocked due to excessive errors" if return_value == 70 && reason == 21
      return "Client IP address blocked for other error" if return_value == 70 && reason == 22
      return "Password does not match current database password" if return_value == 70 && reason == 2 
      return "Password has expired, only a PMDR change password permitted" if return_value == 70 && reason == 3 
      return "Invalid/Unknown Retain userid" if return_value == 69 && reason == 8 
      return "Invalid Eyecatch \"SDIRETEX\"" if return_value == 8 && reason == 16
      return "Userid blank" if return_value == 8 && reason == 12
      return "Password blank" if return_value == 8 && reason == 8 
      return "Userid/Password validated, password will expire in #{reason} days" if return_value == 4
      return "Userid/Password validated, password will expire in #{reason} days" if return_value == 0
      return "Unknown logon error: return value was #{return_value}, reason was #{reason}"
    end

    def not_found_page(exception)
      @exception = exception
      logger.debug("ETAG = '#{response.etag}'")
      render "retain/errors/not_found_page", :layout => "retain/errors", :status => 404
    end

    def sdi_error_page(exception)
      @exception = exception
      render "retain/errors/sdi_error_page", :layout => "retain/errors", :status => 500
    end

    def retain_logon_empty(exception)
      @exception = exception
      render "retain/errors/retain_logon_empty", :layout => "retain/errors", :status => 500
    end

    def retain_logon_short(exception)
      @exception = exception
      render "retain/errors/retain_logon_short", :layout => "retain/errors", :status => 500
    end

    def retain_did_not_read_field(exception)
      @exception = exception
      render "retain/errors/retain_did_not_read_field", :layout => "retain/errors", :status => 500
    end
  end
end
