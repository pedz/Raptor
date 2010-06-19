# -*- coding: utf-8 -*-


require 'retain/utils'

module Retain
  class ConnectionParameters
    attr_reader :signon, :password, :failed, :hardware_node, :software_node
    
    def initialize(retuser)
      super()
      @signon   = retuser.retid.trim(6)
      @password = retuser.password.trim(8)
      @failed   = retuser.failed
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
