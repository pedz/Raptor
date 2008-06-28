module Retain
  module CallUpdateHelper
    def html_tag(update_call, tag, options = { })
      options.merge({
        :id => "#{update_call.to_param}_call_update_#{tag.gsub(/-/, '_')}",
        :class => "call-update-#{tag.gsub(/_/, '-')}"
      })
    end
  end
end
