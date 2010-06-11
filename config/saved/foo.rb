#!/usr/bin/env ruby

require 'yaml'
require 'singleton'

module Retain
  Port = Struct.new(:host, :node, :type, :desc, :port, :test, :offset)
  class Ports
  end
end

base = YAML.load(File.open("config/saved/full-retain.yml"))
base.each_pair do |host, value|
  value.each_pair do |node, node_attrs|
    type = node_attrs[:type]
    node_attrs[:ports].each do |port_spec|
      desc = port_spec[:desc]
      port = port_spec[:port]
      test = port_spec[:test]
      offset = port_spec[:offset]
      port = Retain::Port.new(host, node, type, desc, port, test, offset)
      puts port.to_yaml
    end
  end
end
