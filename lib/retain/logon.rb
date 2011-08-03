# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

require 'singleton'

module Retain
  #
  # Logon is a singleton set by RetainController in a before filter.
  # The biggest client is the SDI code that queries this single for
  # the Retain id, password, and other values that it should use.
  #
  class Logon
    include Singleton

    # retain_user_connection_parameters is a Retain::ConnectionParamters object.
    def set(retain_user_connection_parameters)
      @retain_user_connection_parameters = retain_user_connection_parameters
      @return_value = nil
      @reason = nil
    end

    # Originally, the code used the various fields below.  i.e. there
    # were calls to Logon.instance.signon.  But to make the async
    # processing work, the connection parameters were saved inside the
    # sdi when it was created and then those were used everywhere
    # (within the Retain module).  There are still some calls in the
    # controllers and models to the separate methods.
    def get
      @retain_user_connection_parameters
    end

    # Set the return  value of the logon exchange with the retain
    # node.  This is set by the SDI code and is the "return value" in
    # the "first 50" bytes of the logon sequence.
    def return_value=(value)
      @return_value = value
    end

    # Similar to return_value= except it is how the reason code is set.
    def reason=(value)
      @reason = value
    end

    # Retrieve the return value of the logon sequence.
    def return_value
      @return_value
    end

    # Retrieve the reason code.
    def reason
      @reason
    end

    # Retrieve the original retuser db object -- this clearly needs to
    # be refactored.
    def retuser
      @retain_user_connection_parameters.retuser
    end

    # Retrieve the signon (the Retain id).
    def signon
      @retain_user_connection_parameters.signon
    end

    # Retrieve the Retain password that should be used.
    def password
      @retain_user_connection_parameters.password
    end

    # Retrieve the failed flag
    def failed
      @retain_user_connection_parameters.failed
    end

    # Retrieve the apptest boolean
    def apptest
      @retain_user_connection_parameters.apptest
    end

    # Retrieve the software node
    def software_node
      @retain_user_connection_parameters.software_node
    end

    # Retrieve the hardware node
    def hardware_node
      @retain_user_connection_parameters.hardware_node
    end
  end
end
