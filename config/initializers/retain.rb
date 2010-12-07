# -*- coding: utf-8 -*-


require 'retain'
require 'socket'

Retain::NO_SENDIT = File.exists?(RAILS_ROOT + "/config/no_sendit")

module Retain
  module Debug
    DUMP_SDI = (Rails.env == "development")
    # DUMP_SDI = false
  end
end

begin
  # Load a host specific file.  e.g. tcp237.austin.ibm.com loads a
  # file called tcp237.rb.  That file needs to set TUNNELLED and
  # BASE_PORT.  The default is to not have a file and default to not
  # tunnelled (see rescue below).
  file = Rails.root.join('config', 'saved', Socket.gethostname.sub(/\..*/, '') + '.rb')
  Rails.logger.info("Loading #{file}")
  load(file)
  Rails.logger.info('load worked')
rescue LoadError
  module Retain
    TUNNELLED = false
    BASE_PORT = 0
  end
  Rails.logger.debug('load did not work')
end
