module Retain
  class RetainError < StandardError
  end

  #
  # LogonFailed is raised when a login is attempted but fails.
  #
  class LogonFailed < RetainError
  end

  #
  # Before a login is attempted, the failed boolean is tested.  If it
  # is true, the login attempt is aborted and FailedMarkedTrue is
  # raised.  (We want to not try again or else the user will get
  # locked out.)
  #
  class FailedMarkedTrue < RetainError
  end
end