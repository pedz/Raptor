# -*- coding: utf-8 -*-


module Retain
  Config = YAML.load(File.open("#{RAILS_ROOT}/config/retain.yml")).symbolize_keys
  Config.each do |key, nodes|
    Config[key] = nodes.map { |h| h.symbolize_keys }
  end
  # Rails.logger.debug("Config: #{Config.inspect}")
end
