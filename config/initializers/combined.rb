
require 'combined'
Combined::DB_ONLY = false
Combined::DB_ONLY = true if RAILS_ENV == "development"
