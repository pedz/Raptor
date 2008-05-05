
require 'combined'

Combined::DB_ONLY = File.exists?(RAILS_ROOT + "/config/db_only")
