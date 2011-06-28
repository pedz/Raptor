# -*- coding: utf-8 -*-

ActiveRecord::Base.colorize_logging = false

class ActiveRecord::Base
  # class << self
  #   def as_json_default_options
  #     @as_json_default_optins ||= { }
  #   end
    
  #   def set_as_json_default_options(options)
  #     @as_json_default_optins = options
  #   end
  # end

  # def as_json_with_defaults(options)
  #   self.as_json_without_defaults(self.class.as_json_default_options.merge(options))
  # end
  # alias_method_chain :as_json, :defaults

  def as_json_with_ar_objects(options)
    if options.has_key? :methods
      methods = [ options[:methods] ].push(:ar_objects).flatten.uniq
    else
      methods = :ar_objects
    end
    as_json_without_ar_objects(options.merge(:methods => methods));
  end
  alias_method_chain :as_json, :ar_objects

  def ar_objects
    result = { }
    self.class.reflections.each do |name, reflection|
      options = reflection.options
      # Don't know how to do :through yet so just skip them.
      next if options.has_key? :through
      if options.has_key? :class_name
        class_name = options[:class_name]
      else
        class_name = name.to_s.singularize.camelcase
      end
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
        
        # so far, these two are the same
      when :has_one, :has_many
        hash[:url] = "#{root}/#{self.class.to_s.underscore.pluralize}/#{self.id}/#{name}"
      end
      result[name] = hash
    end
    result
  end
end
