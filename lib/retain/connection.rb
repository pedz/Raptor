
require 'socket'
include Socket::Constants

module Retain
  class Connection
    def initialize
      @socket = Socket.new( AF_INET, SOCK_STREAM, 0 )
      @isconnected = false
      @logger = RAILS_DEFAULT_LOGGER
    end

    # open the connection.  +config+ is a hash of host and port
    # Can raise various exceptions -- see Socket#connect
    def connect(config)
      config = config.symbolize_keys
      puts config[:port]
      puts config[:host]
      sockaddr = Socket.pack_sockaddr_in(config[:port], config[:host])
      @socket.connect(sockaddr)
      @isconnected = true
    end

    def connected?
      @isconnected
    end

    def write(s)
      @socket.write(s)
    end

    def read(n)
      @socket.read(n)
    end
  end
end
