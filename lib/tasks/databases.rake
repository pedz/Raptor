# -*- coding: utf-8 -*-

def db_config(env = RAILS_ENV)
  Rake::Task["rake:environment"].invoke
  ActiveRecord::Base.configurations.symbolize_keys[env]
end

def db_create(config = db_config)
  ActiveRecord::Base.establish_connection(config.symbolize_keys.merge({ :database => 'postgres' }))
  ActiveRecord::Base.connection.create_database(config['database'], config)
end

def db_drop(config = db_config)
  ActiveRecord::Base.establish_connection(config.symbolize_keys.merge({ :database => 'postgres' }))
  ActiveRecord::Base.connection.drop_database(config['database'])
end

def db_migrate(config = db_config)
  ActiveRecord::Base.establish_connection(config)
  Rake::Task["db:migrate"].execute
end

namespace :my do 
  namespace :db do
    namespace :create do 
      task :template do 
        db_create(db_config(:template))
      end

      task :development do 
        db_create(db_config(:development))
      end

      task :broketure do 
        db_create(db_config(:broketure))
      end

      task :test do 
        db_create(db_config(:test))
      end

      task :production do 
        db_create(db_config(:production))
      end
    end

    namespace :drop do 
      task :template do 
        db_drop(db_config(:template))
      end

      task :development do 
        db_drop(db_config(:development))
      end

      task :broketure do 
        db_drop(db_config(:broketure))
      end

      task :test do 
        db_drop(db_config(:test))
      end

      task :production do 
        db_drop(db_config(:production))
      end
    end

    namespace :recreate do
      task :template =>    [ "drop:template",    "create:template" ]
      task :development => [ "drop:development", "create:development" ]
      task :broketure =>   [ "drop:broketure",   "create:broketure" ]
      task :test =>        [ "drop:test",        "create:test" ]
      task :production =>  [ "drop:production",  "create:production" ]
    end

    namespace :migrate do 
      task :template do
        db_migrate(db_config(:template))
      end
    end

    namespace :test do
      task :prepare => [ "my:db:migrate:template", "my:db:recreate:broketure", "my:db:recreate:test" ]
    end

  end
  namespace :test do 
    Rake::TestTask.new(:units => "my:db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'test/unit/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:units'].comment = "Run the unit tests in test/unit"
  end
end
