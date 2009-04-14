require 'action_controller'

module ActiveSupport
  module Rescuable
    protected
      def rescue_with_handler(exception)
        # Special case ActionView::TemplateError exception.  Look at
        # original exception as well
        Rails.logger.debug("hi")
        if ((handler = handler_for_rescue(exception)).nil? &&
            exception.class == ActionView::TemplateError &&
            (temp_exception = exception.original_exception) &&
            (temp_handler = handler_for_rescue(temp_exception)))
          handler = temp_handler
          exception = temp_exception
        end

        if handler
          if handler.arity != 0
            handler.call(exception)
          else
            handler.call
          end
          true # don't rely on the return value of the handler
        end
      end
  end
end

require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      def recreate_database(name) #:nodoc: 
        drop_database(name) 
        create_database(name) 
      end 
 
      # Create a new PostgreSQL database.  Optional options may 
      # include :owner, :template, :encoding, :tablespace, 
      # :connection_limit 
      # 
      # Note that MySQL uses :charset while PostgreSQL uses :encoding 
      # 
      # Example: 
      #   create_database config[:database], config 
      #   create_database 'foo_development', { :encoding => 'unicode' } 
      # 
      def create_database(name, options = {}) 
        options = { :encoding => "utf8" }.merge(options) 
        option_string = options.symbolize_keys.collect do |key, value| 
          case key 
          when :owner 
            " OWNER = '#{value}'" 
          when :template 
            " TEMPLATE = #{value}" 
          when :encoding 
            " ENCODING = '#{value}'" 
          when :tablespace 
            " TABLESPACE = #{value}" 
          when :connection_limit 
            " CONNECTION LIMIT = #{value}" 
          else 
            "" 
          end 
        end.join('') 
        execute "CREATE DATABASE #{name}#{option_string}" 
      end 
 
      # Drops a PostgreSQL database 
      # 
      # Example: 
      #   drop_database 'matt_development' 
      def drop_database(name) #:nodoc: 
        execute "DROP DATABASE IF EXISTS #{name}" 
      end 
    end
  end
end
