
module Combined
  module Common
    def method_missing(symbol, *args, &block)
      logger.debug("CMB: method_missing #{self.class.to_s}##{symbol} for called")
      if block_given?
        # If we have a block, then we call the method and replace the
        # passed in block with our block.  Our block will take each of
        # the yield arguments, replace them, and then call the block
        # we were passed.
        ret = @cached.send(symbol, *args) { |*o_args|
          block.call(* o_args.map { |o| replacement(o) })
        }

        # we need to replace the returned value too.
        replacement(ret)
      else
        # If we were not given a block, then just call the method with
        # the args and replace the return.
        replacement(@cached.send(symbol, *args))
      end
    end

    private

    # 1) If object is an instance of a subclass of Cached, we replace
    #    it with the equivalent Combined object.
    # 2) A hash and other simple objects are returned unchanged.
    # 3) An array is returned as an array with each object being
    #    replace with a recursive call to this routine.
    def replacement(object)
      if object.kind_of? Array then
        if object.respond_to?(:construct_scope) # association_collection
          logger.debug("CMB: #{object.class.to_s} replaced with association")
          Combined::AssociationCollection.new(object)
        else
          logger.debug("CMB: #{object.class.to_s} replaced with array")
          object.map { |o| replacement(o) }
        end
      elsif object.respond_to?(:to_combined)
        logger.debug("CMB: #{object.class.to_s} replaced with db")
        object.to_combined
      else
        logger.debug("CMB: #{object.class.to_s} unchanged")
        object
      end
    end

  end
end
