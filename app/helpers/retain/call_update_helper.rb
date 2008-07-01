module Retain
  module CallUpdateHelper
    def id_for(update_call, tag)
      "call_update_#{tag.gsub(/-/, '_')}_#{update_call.to_id}"
    end

    def html_tag(update_call, tag, options = { })
      options.merge({
        :id => id_for(update_call, tag),
        :class => "call-update-#{tag.gsub(/_/, '-')}"
      })
    end
  end
end
