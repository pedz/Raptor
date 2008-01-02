require 'action_controller'

RAILS_DEFAULT_LOGGER.debug("bananas bananas")

module ActionController
  module Rescue
    protected
      def rescue_action_with_handler(exception)
        RAILS_DEFAULT_LOGGER.debug("bananas 4")
        # Special case ActionView::TemplateError exception.  Look at
        # original exception as well
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
