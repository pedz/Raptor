module ActiveRecord
  module Associations
    class AssociationProxy #:nodoc:
      def send(method, *args, &block)
        if proxy_respond_to?(method)
          super
        else
          load_target
          if block_given?
            @target.send(method, *args, &block)
          else
            @target.send(method, *args)
          end
        end
      end
    end
  end
end
