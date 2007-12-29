
module Retain
  Config = YAML.load(File.open("#{RAILS_ROOT}/config/retain.yml"))
end
