#!/usr/bin/env ruby

# ENV['RAILS_ENV'] = 'development'
require File.dirname(__FILE__) + '/config/boot'
require "#{RAILS_ROOT}/config/environment"

puts RAILS_ENV

p = Retain::ConnectionParameters.new(:host => 'sf2.pok.ibm.com', :port => 3381, :signon => '305356', :password => 'COWS105C')
puts "#{__FILE__}:#{__LINE__}"
Retain::Logon.instance.set(p)
puts "#{__FILE__}:#{__LINE__}"
q = Retain::Queue.new(:queue_name => 'PEDZ', :center => '165')
puts "#{__FILE__}:#{__LINE__}"
recs = q.calls
puts q.queue_name
puts "#{__FILE__}:#{__LINE__}"
rec = recs[0]
puts "#{__FILE__}:#{__LINE__}"
puts "rec is of class #{rec.class}"
puts "rec.problem is #{rec.problem}"
puts "cpu type is #{rec.nls_resolver}"
