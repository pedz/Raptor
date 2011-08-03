# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module ActiveRecord
  module Associations
    class AssociationProxy
      # Override the send method to see if the proxy responds to the
      # message.  If it does, then it is sent to it.  Otherwise, the
      # target is loaded and the message sent to the target.
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
