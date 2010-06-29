# -*- coding: utf-8 -*-


require 'retain/utils'

module Retain

  # ConnectionParameters is a class that holds all that is needed to
  # connect to Retain.  A ConnectionParameters object is created by
  # the RetainController during authorization.
  class ConnectionParameters

    # The user's Retain id
    attr_reader :signon

    # The user's Retain password
    attr_reader :password

    # The value of the failed flag from the Retuser record.  If set,
    # no attempt to access Retain will be made.
    attr_reader :failed

    # This value reflects if we are interacting with APPTEST or not.
    attr_reader :apptest

    # The node to access for a hardware request.  See
    # Retain::Connection.new for details.  This attribute is a hash
    # which has the host, port, and tunnel_offset.
    attr_reader :hardware_node

    # The node to access for a software request.  See
    # Retain::Connection.new for details.  This attribute is a hash
    # which has the host, port, and tunnel_offset.
    attr_reader :software_node
    
    # The Retuser object of the current User is passed in.
    def initialize(retuser)
      super()
      @signon   = retuser.retid.trim(6)
      @password = retuser.password.trim(8)
      @failed   = retuser.failed
      @apptest  = retuser.apptest
      @software_node = {
        :host          => retuser.software_node.retain_node.host,
        :port          => retuser.software_node.retain_node.port,
        :tunnel_offset => retuser.software_node.retain_node.tunnel_offset
      }
      @hardware_node = {
        :host          => retuser.hardware_node.retain_node.host,
        :port          => retuser.hardware_node.retain_node.port,
        :tunnel_offset => retuser.hardware_node.retain_node.tunnel_offset
      }
    end
  end
end
