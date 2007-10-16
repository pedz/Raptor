namespace :db do
  def create_database(config)
    begin
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection
    rescue
      case config['adapter']
      when 'mysql'
        @charset   = ENV['CHARSET']   || 'utf8'
        @collation = ENV['COLLATION'] || 'utf8_general_ci'
        begin
          ActiveRecord::Base.establish_connection(config.merge({'database' => nil}))
          ActiveRecord::Base.connection.create_database(config['database'], {:charset => @charset, :collation => @collation})
          ActiveRecord::Base.establish_connection(config)
        rescue
          $stderr.puts "Couldn't create database for #{config.inspect}"
        end
      when 'postgresql'
        `createdb -E utf8 "#{config['database']}"`
      when 'sqlite'
        `sqlite "#{config['database']}"`
      when 'sqlite3'
        `sqlite3 "#{config['database']}"`
      end
    else
      p "#{config['database']} already exists"
    end
  end
end
