# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # Config is a constant loaded at start time that comes from the
  # config/retain.yml file.  This hash table is then used to determine
  # which host / port to use.
  Config = YAML.load(File.open("#{RAILS_ROOT}/config/retain.yml")).symbolize_keys
  Config.each do |key, nodes|
    Config[key] = nodes.map { |h| h.symbolize_keys }
  end
  # Rails.logger.debug("Config: #{Config.inspect}")
end
