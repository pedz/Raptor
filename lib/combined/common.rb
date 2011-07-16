# -*- coding: utf-8 -*-

module Combined
  # Common instance routines included by both Base and
  # AssociationProxy.
  module Common
    alias_method :proxy_respond_to?, :respond_to?

    # instance method that returns true if the combined object
    # responds to the message or if the cached object does.
    def respond_to?(symbol, include_private=false)
      proxy_respond_to?(symbol, include_private) or
        @cached.respond_to?(symbol, include_private)
    end
    
    # For all methods coming to the combined object that are not known
    # to us, we forward on to the cached object.  But the args need to
    # be unwrapped first.  And, the results need to be wrapped back
    # up.
    def method_missing(symbol, *args, &block)
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
        ret = @cached.send(symbol, *args) { |*o_args|
          block.call(* o_args.map { |o| o.wrap_with_combined })
        }

        # we need to replace the returned value too.
        ret.wrap_with_combined
      else
        # If we were not given a block, then just call the method with
        # the args and replace the return.
        @cached.send(symbol, *args).wrap_with_combined
      end
    end
  end
end
