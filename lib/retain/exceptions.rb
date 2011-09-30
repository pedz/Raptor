# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # Parent class for other errors thrown by the Retain module.
  class RetainError < StandardError
    # Initialized in config/initializers/loggers.rb
    cattr_accessor :logger
  end

  #
  # LogonFailed is raised when a login is attempted but fails.
  #
  class LogonFailed < RetainError
    attr_reader :retain_user_connection_parameters, :logon_return, :logon_reason

    def initialize(retain_user_connection_parameters, logon_return, logon_reason)
      retain_user_connection_parameters, @logon_return, @logon_reason = retain_user_connection_parameters, logon_return, logon_reason
    end
  end

  #
  # Before a login is attempted, the failed boolean is tested.  If it
  # is true, the login attempt is aborted and FailedMarkedTrue is
  # raised.  (We want to not try again or else the user will get
  # locked out.)
  #
  class FailedMarkedTrue < RetainError
  end

  # Sometimes the logon sequence returns nothing
  class RetainLogonEmpty < RetainError
  end

  # From above, I assume it is possible for it to return less than the proper 35 bytes.
  class RetainLogonShort < RetainError
  end

  # We are getting weird socket errors.  This is here as a generic way
  # to get those back to the user and also to me so I know more about
  # what is going on.
  class SDIError < RetainError
    attr_reader :sdi

    def initialize(msg, sdi, backtrace = caller)
      super(msg)
      @sdi = sdi
      set_backtrace(backtrace)
      logger.error(msg)
      logger.error(backtrace.join("\n"))
      sdi.logon_debug
      sdi.dump_debug
    end
  end
end
