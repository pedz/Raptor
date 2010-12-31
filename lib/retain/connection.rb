# -*- coding: utf-8 -*-

require 'socket'
include Socket::Constants

module Retain
  # The Retain::Sdi uses Retain::Connection to create a socket and
  # communicate over it.  Connection takes care of the lowest level
  # work.
  class Connection
    # Initialized in config/initializers/loggers.rb
    cattr_accessor :logger
    
    # class variable used to count the number of times a Connection is
    # created.
    @@count = 0
    # class variable used to keep track of the total time spent
    # connecting, reading, and writing over the Connection.
    @@time = 0

    # class method to reset the time and use counters
    def self.reset_time
      @@count = 0
      @@time = 0
    end

    # Retrieves the number of Connections made since reset_time was called.
    def self.request_count
      @@count
    end

    # Retrieves the total time consued by calls to Connections.
    def self.total_time
      @@time
    end

    # The h_or_s argument is used to determine whether the
    # hardware_node (when set to "H") or the software_node (default or
    # when set to "S") should be used.
    def initialize(node)
      super()
      # logger.debug("RTN: Connection initialize h_or_s is '#{h_or_s}'")
      @@count += 1
      @socket = Socket.new( AF_INET, SOCK_STREAM, 0 )
      @node = node
    end

    # Returns the Retain Node being accessed.
    def node
      @node
    end
    
    # Returns the host being accessed.
    def host
      @host
    end

    # Returns the port being accessed.
    def port
      @port
    end

    # open the connection.  +config+ is a hash of host and port
    # Can raise various exceptions -- see Socket#connect
    def connect
      if Retain::TUNNELLED
        @host = 'localhost'
        @port = Retain::BASE_PORT + @node[:tunnel_offset]
        logger.info("RTN: Connecting to #{@node[:host]} #{@node[:port]} via #{@host} #{@port}")
      else
        @host = @node[:host]
        @port = @node[:port]
        logger.info("RTN: Connecting directly to #{@host} #{@port}")
      end
      sockaddr = Socket.pack_sockaddr_in(@port, @host)
      @socket.connect(sockaddr)
    end

    # write +s+ to the connection
    def write(s)
      @socket.write(s)
    end

    # read up to n bytes from the connection
    def read(n)
      @socket.read(n)
    end

    private

    # Hooked into the connect chain so that time and use benchmarks
    # can be gathered.
    def connect_with_benchmark
      result = nil
      real_time = Benchmark.realtime { result = connect_without_benchmark }
      @@time += real_time
      result
    end
    alias_method_chain :connect, :benchmark

    # Hooked into the write chain
    def write_with_benchmark(s)
      result = nil
      real_time = Benchmark.realtime { result = write_without_benchmark(s) }
      @@time += real_time
      result
    end
    alias_method_chain :write, :benchmark

    # Hooked into the read chain.
    def read_with_benchmark(n)
      result = nil
      real_time = Benchmark.realtime { result = read_without_benchmark(n) }
      @@time += real_time
      result
    end
    alias_method_chain :read, :benchmark

  end
end
