
ActiveRecord::Base.colorize_logging = false

class ActiveRecord::Base
  class << self
    def as_json_default_options
      @as_json_default_optins ||= { }
    end
    
    def set_as_json_default_options(options)
      @as_json_default_optins = options
    end
  end

  def as_json_with_defaults(options)
    self.as_json_without_defaults(self.class.as_json_default_options.merge(options))
  end
  alias_method_chain :as_json, :defaults
end
