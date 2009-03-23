require 'action_view/helpers/asset_tag_helper'

module ActionView
  module Helpers
    module AssetTagHelper
      def icon_path(source)
        compute_public_path(source, '.')
      end

      def icon_tag(source, options = {})
        options.symbolize_keys!
        options[:href] ||= icon_path(source)
        options[:rel] ||= 'icon'
        tag("link", options)
      end
    end
  end
end
