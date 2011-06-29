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
    rescue_from Errno::ECONNREFUSED,        :with => :cannot_reach_retain

    # The @retain_user_connection_parameters attribute, the
    # retain_user_connection_parameters method, the @signon_user
    # attribute, and the signon_user method seem to be a bit redundant
    # and I suppose they are.
    #
    # The signon_user and @signon_user attribute were created to have
    # a way to pass values to use as defaults for some of the retain
    # fields.  For example, if a user does a request for queue "foo",
    # the h_or_s field and the center are not specified.  The defaults
    # for these would come from the signon_user's h_or_s and center
    # fields respectively.
    #
    # The retain_user_connection_parameters is (I hope) what the name
    # implies.  It is a bucket of stuff that is used to make a
    # connection to retain and also has a few fields as to the results
    # of the attemp of the connection.
    def signon_user
      # 2011-03-25 -- This was find_or_initialize but if we start of
      # with an empty database and do a QS, we end up creating a
      # cached registration for this user because (usually) they will
      # have a PMR that they own.  Then later, we try and get the
      # PSARs.  The new record does not have the psar_number so we
      # fetch it and try to insert it (because its new) but that
      # fails.  So... lets try and just create it here so later will
      # we do updates as it changes.
      @signon_user ||=
        Combined::Registration.find_or_create_by_signon_and_apptest(@retain_user_connection_parameters.signon,
                                                                    @retain_user_connection_parameters.apptest)
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
      if (retuser = application_user.current_retain_id).nil?
        # logger.debug("RTN: nil current_retain_id")
        session[:original_uri] = request.request_uri
        redirect_to new_user_retuser_url(application_user)
        return false
      end

      if retuser.failed
        flash[:warning] = find_logon_error(retuser.logon_return, retuser.logon_reason)
        common_failed_logon(retuser)
        return false
      end

      setup_logon_instance
      return true
    end

    def retain_user_connection_parameters
      @retain_user_connection_parameters
    end

    # Pull together the signon/password and the host/port and create a
    # ConnectionParamters structure.  We hold this in the session
    # data.  We also set the Logon instance to use these settings.
    def setup_logon_instance
      retuser = application_user.current_retain_id
      @retain_user_connection_parameters = ConnectionParameters.new(retuser)
      # logger.debug("params 2 = #{@retain_user_connection_parameters.inspect}")
      # The Logon instance is the way we pass @retain_user_connection_parameters from the Retain
      # controller to any Combined models.  The Combined models then
      # pass it explicitly to any Retain models that they need.
      # logger.debug("Logon set")
      Logon.instance.set(@retain_user_connection_parameters)
    end
    
    def logon_failed(exception)
      # logger.debug("logon failed")
      # Find the retuser record and set the failed bit to true so we
      # do not retry until the user resets his password.
      retuser = application_user.current_retain_id
      retuser.failed = true
      retuser.logon_return = exception.logon_return
      retuser.logon_reason = exception.logon_reason
      retuser.save

      flash[:error] = find_logon_error(retuser.logon_return, retuser.logon_reason)
      common_failed_logon(retuser)
    end

    def failed_marked_true(exception)
      retuser = application_user.current_retain_id
      flash[:warning] = find_logon_error(retuser.logon_return, retuser.logon_reason)
      common_failed_logon(retuser)
    end

    def common_failed_logon(retuser)
      # Remember what we were trying to do
      session[:original_uri] = request.request_uri
      redirect_to edit_user_retuser_url(application_user, retuser)
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
    def find_logon_error(logon_return, logon_reason)
      return "Retain database not available for userid validation" if logon_return == 16 && logon_reason == 18
      return "Userid is set to inactive" if logon_return == 70 && logon_reason == 19
      return "Userid is being blocked due to excessive errors" if logon_return == 70 && logon_reason == 20
      return "Client IP address being blocked due to excessive errors" if logon_return == 70 && logon_reason == 21
      return "Client IP address blocked for other error" if logon_return == 70 && logon_reason == 22
      return "Password does not match current database password" if logon_return == 70 && logon_reason == 2 
      return "Password has expired, only a PMDR change password permitted" if logon_return == 70 && logon_reason == 3 
      return "Invalid/Unknown Retain userid" if logon_return == 69 && logon_reason == 8 
      return "Invalid Eyecatch \"SDIRETEX\"" if logon_return == 8 && logon_reason == 16
      return "Userid blank" if logon_return == 8 && logon_reason == 12
      return "Password blank" if logon_return == 8 && logon_reason == 8 
      return "Userid/Password validated, password will expire in #{logon_reason} days" if logon_return == 4
      return "Userid/Password validated, password will expire in #{logon_reason} days" if logon_return == 0
      return "Unknown logon error: return value was #{logon_return}, reason was #{logon_reason}"
    end

    def not_found_page(exception)
      @exception = exception
      # logger.debug("ETAG = '#{response.etag}'")
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
      logger.error(exception.message)
      logger.error("Did not read #{exception.field_name}")
      logger.error(exception.backtrace.join("\n"))
      render "retain/errors/retain_did_not_read_field", :layout => "retain/errors", :status => 500
    end

    def cannot_reach_retain(exception)
      @exception = exception
      logger.error("Errno::ECONNREFUSED caught -- can not reach retain")
      logger.error(exception.message)
      logger.error(exception.backtrace.join("\n"))
      render "retain/errors/cannot_reach_retain", :layout => "retain/errors", :status => 500
    end
  end
end
