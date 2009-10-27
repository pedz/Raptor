# -*- coding: utf-8 -*-


require 'retain/utils'

module Retain
  class ConnectionParameters
    attr_reader :host, :port, :signon, :password, :failed
    
    def initialize(options)
      super()
      @host     = options[:host]
      @port     = options[:port]
      @signon   = options[:signon].trim(6)
      @password = options[:password].trim(8)
      @failed   = options[:failed]
    end
  end
end
