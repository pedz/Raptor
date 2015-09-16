unless defined?(ENABLE_RAILS_FOOTNOTES)
  ENABLE_RAILS_FOOTNOTES=(RAILS_ENV == 'development')
end
if ENABLE_RAILS_FOOTNOTES
  dir = File.dirname(__FILE__)
  require File.join(dir, 'rails-footnotes', 'footnotes')
  require File.join(dir, 'rails-footnotes', 'backtracer')

  # Load all notes
  #
  Dir[File.join(dir, 'rails-footnotes', 'notes', '*.rb')].sort.each do |note|
    require note
  end

  # The footnotes are applied by default to all actions. You can change this
  # behavior commenting the after_filter line below and putting it in Your
  # application. Then you can cherrypick in which actions it will appear.
  #
  class ActionController::Base
    prepend_before_filter Footnotes::Filter
    after_filter Footnotes::Filter

    # prefer our own rescue views when available
    def rescue_action_locally(exception)
      class << RESCUES_TEMPLATE_PATH
        def [](path)
          footnotes_views_path = File.join(File.dirname(__FILE__), 'rails-footnotes/views')
          if File.exists? File.join(footnotes_views_path, path)
            ActionView::Template::EagerPath.new_and_loaded(footnotes_views_path)[path]
          else
            super
          end
        end
      end
      super
    end
  end
end
