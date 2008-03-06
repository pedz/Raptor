puts "loggers init"
require 'retain'
puts "retain is loaded"
puts "logger is #{RAILS_DEFAULT_LOGGER}"
Retain::Base.logger = RAILS_DEFAULT_LOGGER
Retain::Connection.logger = RAILS_DEFAULT_LOGGER
Retain::Fields.logger = RAILS_DEFAULT_LOGGER
Retain::Request.logger = RAILS_DEFAULT_LOGGER
Retain::Sdi.logger = RAILS_DEFAULT_LOGGER
Retain::SignatureLine.logger = RAILS_DEFAULT_LOGGER

require 'combined'
Combined::Base.logger = RAILS_DEFAULT_LOGGER
Combined::AssociationProxy.logger = RAILS_DEFAULT_LOGGER

require 'cached'
Cached::Base.logger = RAILS_DEFAULT_LOGGER
