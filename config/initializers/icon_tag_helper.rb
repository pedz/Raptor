require 'action_view/helpers/asset_tag_helper'

module ActionView
  module Helpers
    module AssetTagHelper
      def icon_path(source)
        IconTag.new(self, @controller, source).public_path
      end

      def icon_tag(source, options = {})
        options.symbolize_keys!
        options[:href] ||= icon_path(source)
        options[:rel] ||= 'icon'
        tag("link", options)
      end

      private

      module IconAsset
        DIRECTORY = ''.freeze
        EXTENSION = 'ico'.freeze
        
        def directory
          DIRECTORY
        end

        def extension
          EXTENSION
        end
      end

      class IconTag < AssetTag
        include IconAsset
      end
    end
  end
end
