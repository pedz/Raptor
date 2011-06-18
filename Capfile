# -*- coding: utf-8 -*-
# -*- ruby -*-

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

namespace :deploy do
  desc "Play task"
  task :play, :roles => :app do
    run "echo #{deploy_to}"
  end
  
  desc "Clear the production log via rake"
  task :log_clear, :roles => :app do
    run "cd #{current_path}/ && rake log:clear"
  end

  desc "The start task is used by :cold_deploy to start the application up"
  task :start, :roles => :app do
    # For thin
    run "/etc/rc.d/init.d/raptor start"
  end

  desc "Restart the application"
  task :restart, :roles => :app do
    # For thin
    run "/etc/rc.d/init.d/raptor restart"

    # For Passenger
    # run "rm -f  #{current_path}/tmp/restart.txt; touch #{current_path}/tmp/restart.txt"
  end

  desc "Stop the application"
  task :stop, :roles => :app do
    # For thin
    run "/etc/rc.d/init.d/raptor stop"
  end

  # desc "Hook to set up database.yml"
  # task :after_update_code, :roles => :app do
  #   run "cp #{db_path} #{release_path}/config/database.yml"
  #   run "cp #{retain_path} #{release_path}/config/retain.yml"
  # end
end

after "deploy:update_code" do
  run "cp #{db_path} #{release_path}/config/database.yml"
  run "cp #{retain_path} #{release_path}/config/retain.yml"
end
