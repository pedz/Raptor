# -*- coding: utf-8 -*-

# Returns the current git head
def git_head
  Kernel.open("| git symbolic-ref HEAD").readlines[0].chomp.sub(/.*\//, '')
end

desc "Pushs git repository to production server"
task :sync_production do
  sh "git push lab --all"
end

desc "Deploy to production server"
task :deploy => [ :sync_production ] do
  sh "cap production deploy"
end

desc "Pushs git repository to staging server"
task :sync_staging do
  sh "git push p51 --all"
end

desc "Deploy to staging server"
task :stage => [ :sync_staging ] do
  sh "cap staging deploy"
end

namespace :deploy do
  desc 'Test deployment dependencies.'
  task :check => [ :sync_production ] do
    sh "cap production deploy:check"
  end

  desc 'Clean up old releases.'
  task :cleanup => [ :sync_production ] do
    sh "cap production deploy:cleanup"
  end

  desc "Deploys and starts a `cold' application."
  task :cold => [ :sync_production ] do
    sh "cap production deploy:cold"
  end

  desc 'Clear the production log via rake.'
  task :log_clear => [ :sync_production ] do
    sh "cap production deploy:log_clear"
  end

  desc 'Run the migrate rake task.'
  task :migrate => [ :sync_production ] do
    sh "cap production deploy:migrate"
  end

  desc 'Deploy and run pending migrations'
  task :migrations => [ :sync_production ] do
    sh "cap production deploy:migrations"
  end

  desc 'Displays the commits since your last deploy.'
  task :pending => [ :sync_production ] do
    sh "cap production deploy:pending"
  end

  namespace :pending do
    desc "Displays the `diff' since your last deploy."
    task :diff => [ :sync_production ] do
      sh "cap production deploy:pending:diff"
    end
  end

  desc 'Play task.'
  task :play => [ :sync_production ] do
    sh "cap production deploy:play"
  end

  desc 'Restart the application.'
  task :restart => [ :sync_production ] do
    sh "cap production deploy:restart"
  end

  desc 'Rolls back to a previous version and restarts.'
  task :rollback => [ :sync_production ] do
    sh "cap production deploy:rollback"
  end

  desc 'Prepares one or more servers for deployment.'
  task :setup => [ :sync_production ] do
    sh "cap production deploy:setup"
  end

  desc 'The start task is used by :cold_deploy to start the application up.'
  task :start => [ :sync_production ] do
    sh "cap production deploy:start"
  end

  desc 'No way to stop the application.'
  task :stop => [ :sync_production ] do
    sh "cap production deploy:stop"
  end

  desc 'Updates the symlink to the most recently deployed version.'
  task :symlink => [ :sync_production ] do
    sh "cap production deploy:symlink"
  end

  desc 'Copies your project and updates the symlink.'
  task :update => [ :sync_production ] do
    sh "cap production deploy:update"
  end

  desc 'Copies your project to the remote servers.'
  task :update_code => [ :sync_production ] do
    sh "cap production deploy:update_code"
  end

  desc 'Copy files to the currently deployed version.'
  task :upload => [ :sync_production ] do
    sh "cap production deploy:upload"
  end

  namespace :web do
    desc 'Disable the web application'
    task :disable do
      sh "cap production deploy:web:disable"
    end

    desc 'Enable the web application'
    task :enable do
      sh "cap production deploy:web:enable"
    end
  end
end

namespace :stage do
  desc 'Test deployment dependencies.'
  task :check => [ :sync_staging ] do
    sh "cap staging deploy:check"
  end

  desc 'Clean up old releases.'
  task :cleanup => [ :sync_staging ] do
    sh "cap staging deploy:cleanup"
  end

  desc "Deploys and starts a `cold' application."
  task :cold => [ :sync_staging ] do
    sh "cap staging deploy:cold"
  end

  desc 'Clear the staging log via rake.'
  task :log_clear => [ :sync_staging ] do
    sh "cap staging deploy:log_clear"
  end

  desc 'Run the migrate rake task.'
  task :migrate => [ :sync_staging ] do
    sh "cap staging deploy:migrate"
  end

  desc 'Deploy and run pending migrations'
  task :migrations => [ :sync_staging ] do
    sh "cap staging deploy:migrations"
  end

  desc 'Displays the commits since your last deploy.'
  task :pending => [ :sync_staging ] do
    sh "cap staging deploy:pending"
  end

  namespace :pending do
    desc "Displays the `diff' since your last deploy."
    task :diff => [ :sync_staging ] do
      sh "cap staging deploy:pending:diff"
    end
  end

  desc 'Play task.'
  task :play => [ :sync_staging ] do
    sh "cap staging deploy:play"
  end

  desc 'Restart the application.'
  task :restart => [ :sync_staging ] do
    sh "cap staging deploy:restart"
  end

  desc 'Rolls back to a previous version and restarts.'
  task :rollback => [ :sync_staging ] do
    sh "cap staging deploy:rollback"
  end

  desc 'Prepares one or more servers for deployment.'
  task :setup => [ :sync_staging ] do
    sh "cap staging deploy:setup"
  end

  desc 'The start task is used by :cold_deploy to start the application up.'
  task :start => [ :sync_staging ] do
    sh "cap staging deploy:start"
  end

  desc 'No way to stop the application.'
  task :stop => [ :sync_staging ] do
    sh "cap staging deploy:stop"
  end

  desc 'Updates the symlink to the most recently deployed version.'
  task :symlink => [ :sync_staging ] do
    sh "cap staging deploy:symlink"
  end

  desc 'Copies your project and updates the symlink.'
  task :update => [ :sync_staging ] do
    sh "cap staging deploy:update"
  end

  desc 'Copies your project to the remote servers.'
  task :update_code => [ :sync_staging ] do
    sh "cap staging deploy:update_code"
  end

  desc 'Copy files to the currently deployed version.'
  task :upload => [ :sync_staging ] do
    sh "cap staging deploy:upload"
  end

  namespace :web do
    desc 'Disable the web application'
    task :disable do
      sh "cap staging deploy:web:disable"
    end

    desc 'Enable the web application'
    task :enable do
      sh "cap staging deploy:web:enable"
    end
  end
end
