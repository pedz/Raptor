# -*- ruby -*-

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
load 'config/deploy'

namespace :deploy do
  desc "Play task"
  task :play, :roles => :app do
    run "echo #{deploy_to}"
  end
  
  desc "The start task is used by :cold_deploy to start the application up"
  task :start, :roles => :app do
    run "cd #{current_path}/ && mongrel_rails cluster::start"
  end

  desc "Restart the mongrel cluster"
  task :restart, :roles => :app do
    run "cd #{current_path}/ && mongrel_rails cluster::restart"
  end

  desc "Stop the mongrel cluster"
  task :stop, :roles => :app do
    run "cd #{current_path}/ && mongrel_rails cluster::stop"
  end

  desc "Hook to set up database.yml"
  task :after_update_code, :roles => :app do
    run "cp #{db_path} #{release_path}/config/database.yml"
  end
end