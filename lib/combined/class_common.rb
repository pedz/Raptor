module Combined
  module ClassCommon
    alias_method :proxy_respond_to?, :respond_to?
    
    # respond_to? class method
    def respond_to?(symbol, include_private=false)
      proxy_respond_to?(symbol, include_private) or
        cached_class.respond_to?(symbol, include_private)
    end
    
    def method_missing(symbol, *args, &block)
      args = args.unwrap_to_cached
      
      if block_given?
        # If we have a block, then we call the method and replace the
        # passed in block with our block.  Our block will take each of
        # the yield arguments, replace them, and then call the block
        # we were passed.
        ret = cached_class.send(symbol, *args) { |*o_args|
          block.call(* o_args.map { |o| o.wrap_with_combined })
        }
        
        # we need to replace the returned value too.
        ret.wrap_with_combined
      else
        # If we were not given a block, then just call the method with
        # the args and replace the return.
        cached_class.send(symbol, *args).wrap_with_combined
      end
    end
  end
end
