
require 'socket'
include Socket::Constants

module Retain
  class Connection
    def initialize
      @socket = Socket.new( AF_INET, SOCK_STREAM, 0 )
      @logger = RAILS_DEFAULT_LOGGER
    end

    # open the connection.  +config+ is a hash of host and port
    # Can raise various exceptions -- see Socket#connect
    def connect
      sockaddr = Socket.pack_sockaddr_in(Logon.instance.port, Logon.instance.host)
      @socket.connect(sockaddr)
    end

    def write(s)
      @socket.write(s)
    end

    def read(n)
      @socket.read(n)
    end
  end
end
