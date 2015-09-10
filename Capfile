# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
require 'capistrano/bundler'
# require 'capistrano/rails/assets'
# require 'capistrano/rails/migrations'
# require 'capistrano/passenger'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }


namespace :deploy do
  desc "Play task"
  task :play, :roles => :app do
    run "echo #{deploy_to}"
  end
  
  desc "Clear the production log via rake"
  task :log_clear, :roles => :app do
    run "cd #{current_path}/ && log/.old/save-log"
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
end
