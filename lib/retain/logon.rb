# -*- coding: utf-8 -*-

require 'singleton'

module Retain
  #
  # Logon is a singleton set by RetainController in a before filter.
  # The biggest client is the SDI code that queries this single for
  # the Retain id, password, and other values that it should use.
  #
  class Logon
    include Singleton

    # params is a Retain::ConnectionParamters object.
    def set(params)
      @params = params
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
      @params
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
      @params.retuser
    end

    # Retrieve the signon (the Retain id).
    def signon
      @params.signon
    end

    # Retrieve the Retain password that should be used.
    def password
      @params.password
    end

    # Retrieve the failed flag
    def failed
      @params.failed
    end

    # Retrieve the apptest boolean
    def apptest
      @params.apptest
    end

    # Retrieve the software node
    def software_node
      @params.software_node
    end

    # Retrieve the hardware node
    def hardware_node
      @params.hardware_node
    end
  end
end
