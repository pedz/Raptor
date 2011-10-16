# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

STDERR.puts "I'm on '#{system "hostname"}"
unless respond_to?(:env)
  STDERR.puts "Please use --set-before env=<env>"
  exit 1
end

if env == 'production'
  set :domain,      "raptor@tcp237.austin.ibm.com"
elsif env == 'staging'
  set :domain,      "raptor@p51.austin.ibm.com"
else
  STDERR.puts "env must be 'production' or 'staging'"
  exit 1
end

# Added for RVM
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.

require "rvm/capistrano"  # Load RVM's capistrano plugin.
require "bundler/capistrano" # Load Bundler's capistrano plugin.

# set environment
set :rvm_ruby_string, 'ruby-1.9.2-p290@raptor'

set :application,  "raptor"
set :repository,   "#{domain}:repositories/raptor.git"
set :scm,          :git
set :branch,       "master"

# deploy_base is my own variable that is the base of where all the
# rails applications live.
set :deploy_base,  "/usr/local/www"

# The real database.yml is kept out of the tree in this path
set :db_path,     "#{deploy_base}/database-files/#{application}-database.yml"
set :retain_path, "#{deploy_base}/database-files/#{application}-retain.yml"

# The deploy_to is a variable that Capistrano needs
set :deploy_to, "#{deploy_base}/#{application}"
set :use_sudo, false

role :app, domain
role :web, domain
role :db,  domain, :primary => true
