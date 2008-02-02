#
# This is a separate module only because I thought I needed
# Combined::AssociationCollection.  But, currently, I do not think I
# do.  So, this could be moved into base.rb
#
module Combined
  module Common
    alias_method :proxy_respond_to?, :respond_to?

    def respond_to?(symbol, include_private=false)
      logger.debug("CMB: respond_to? #{symbol} for <#{self.class}:#{self.object_id}> called")
      proxy_respond_to?(symbol, include_private) or
        self.cached.respond_to?(symbol, include_private)
    end
    
    #
    # For all methods coming to the combined object that are not known
    # to us, we forward on to the cached object.  But the args need to
    # be unwrapped first.  And, the results need to be wrapped back
    # up.
    #
    def method_missing(symbol, *args, &block)
      logger.debug("CMB: method_missing #{symbol} for <#{self.class}:#{self.object_id}> called")
      logger.debug("CMB: args = #{args.inspect}")
      cached = self.cached
      args = args.unwrap_to_cached
      if block_given?
        #
        # If we have a block, then we call the method and replace the
        # passed in block with our block.  Our block will take each of
        # the yield arguments, replace them, and then call the block
        # we were passed.
        #
        # This was added to get the erb code to work properly.
        #
        ret = cached.send(symbol, *args) { |*o_args|
          block.call(* o_args.map { |o| o.wrap_with_combined })
        }

        # we need to replace the returned value too.
        ret.wrap_with_combined
      else
        # If we were not given a block, then just call the method with
        # the args and replace the return.
        cached.send(symbol, *args).wrap_with_combined
      end
    end
  end
end

####      # 1) If object is an instance of a subclass of Cached, we replace
####      #    it with the equivalent Combined object.
####      # 2) An array is returned as an array with each object being
####      #    replaced with a recursive call to this routine.
####      # 3) The values of a hash are replaced.
####      # 4) Any other objects are returned unchanged.
####      def wrap(object)
####        if object.kind_of? Array then
####          # if object.respond_to?(:construct_scope) # association_collection
####          #   logger.debug("CMB: wrap #{object.class.to_s} replaced with association")
####          #   Combined::AssociationCollection.new(object)
####          # else
####            logger.debug("CMB: wrap #{object.class.to_s} replaced with array")
####            object.map { |o| wrap(o) }
####          # end
####        elsif object.kind_of? Hash then
####          logger.debug("CMB: wrap hash values replaced")
####          object.inject({}) { |o, a| o[a[0]] = wrap(a[1]); o }
####        elsif object.respond_to?(:to_combined)
####          logger.debug("CMB: wrap #{object.class.to_s} replaced with combined")
####          object.to_combined
####        else
####          logger.debug("CMB: wrap #{object.class.to_s} unchanged")
####          object
####        end
####      end
####  
####      # The opposite of wrap:
####      # 1) If object is an instance of a subclass of Combined, we
####      #    replace it with the equivalent Cached object.
####      # 2) An array is returned as an array with each object being
####      #    replaced with a recursive call to this routine.
####      # 3) The values of a hash are replaced.
####      # 4) Any other objects are returned unchanged.
####      def unwrap(object)
####        if object.kind_of? Array then
####          # if object.respond_to?(:construct_scope) # association_collection
####          #   logger.debug("CMB: unwrap #{object.class.to_s} replaced with association")
####          #   Combined::AssociationCollection.new(object)
####          # else
####            logger.debug("CMB: unwrap #{object.class.to_s} replaced with array")
####            object.map { |o| unwrap(o) }
####          # end
####        elsif object.kind_of? Hash then
####          logger.debug("CMB: unwrap hash values replaced")
####          object.inject({}) { |o, a| o[a[0]] = unwrap(a[1]); o }
####        elsif object.respond_to?(:cached)
####          logger.debug("CMB: unwrap #{object.class.to_s} replaced with cached")
####          object.cached
####        else
####          logger.debug("CMB: unwrap #{object.class.to_s} unchanged")
####          object
####        end
####      end
