# -*- coding: utf-8 -*-


require 'socket'
include Socket::Constants

module Retain
  class Connection
    cattr_accessor :logger
    
    @@count = 0
    @@time = 0

    def self.reset_time
      @@count = 0
      @@time = 0
    end

    def self.request_count
      @@count
    end

    def self.total_time
      @@time
    end

    def initialize(h_or_s)
      super()
      # logger.debug("RTN: Connection initialize h_or_s is '#{h_or_s}'")
      @@count += 1
      @socket = Socket.new( AF_INET, SOCK_STREAM, 0 )
      @h_or_s = h_or_s
    end

    # open the connection.  +config+ is a hash of host and port
    # Can raise various exceptions -- see Socket#connect
    def connect
      if @h_or_s == 'H' then
        node = RetainConfig::HARDWARE_NODES[RetainConfig::NodeIndex]
      else
        node = RetainConfig::SOFTWARE_NODES[RetainConfig::NodeIndex]
      end
      node_hash = Retain::Config[node][0]
      # logger.debug("RTN: Connecting to #{node_hash[:host]} #{node_hash[:port]}")
      sockaddr = Socket.pack_sockaddr_in(node_hash[:port], node_hash[:host])
      @socket.connect(sockaddr)
    end

    def write(s)
      @socket.write(s)
    end

    def read(n)
      @socket.read(n)
    end

    private

    def connect_with_benchmark
      result = nil
      real_time = Benchmark.realtime { result = connect_without_benchmark }
      @@time += real_time
      result
    end
    alias_method_chain :connect, :benchmark

    def write_with_benchmark(s)
      result = nil
      real_time = Benchmark.realtime { result = write_without_benchmark(s) }
      @@time += real_time
      result
    end
    alias_method_chain :write, :benchmark

    def read_with_benchmark(n)
      result = nil
      real_time = Benchmark.realtime { result = read_without_benchmark(n) }
      @@time += real_time
      result
    end
    alias_method_chain :read, :benchmark

  end
end
