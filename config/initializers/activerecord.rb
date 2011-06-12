
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

  def ar_objects
    result = { }
    self.class.reflections.each do |name, reflection|
      options = reflection.options
      class_name = options[:class_name]
      klass = class_name.constantize
      root = ActionController::Base.relative_url_root + "/json"
      hash = {
        :class_name => class_name,
        :association_type => reflection.macro
      }
      
      case reflection.macro
      when :belongs_to
        if options.has_key? :foreign_key
          id = self.attributes[options[:foreign_key]]
        else
          id = self.attributes["#{name}_id"]
        end
        # I think this is what I wanna do...
        if id.nil?
          result[name] = nil
          next
        end
        hash[:id] = id
        hash[:url] = "#{root}/#{class_name.underscore.pluralize}/#{hash[:id]}"
        if self.send("loaded_#{name}?")
          hash[:element] = self.send(name).as_json({ :methods => :ar_objects })
        end
        
        # so far, these two are the same
      when :has_one, :has_many
        hash[:url] = "#{root}/#{self.class.to_s.underscore.pluralize}/#{self.id}/#{name}"
        if self.send(name).loaded?
          hash[:element] = self.send(name).as_json({ :methods => :ar_objects })
        end
      end
      result[name] = hash
    end
    result
  end
end
