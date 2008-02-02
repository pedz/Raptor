
class Object
  #
  # The unwrap to cached will take an object and return the cached
  # object if it is a combined object.  But for the general case, we
  # just return the object.
  #
  def unwrap_to_cached
    if self.respond_to? :cached
      raise "Object#unwrap_to_cached called with Combined object"
    else
      RAILS_DEFAULT_LOGGER.debug("CMB: unwrap Object <#{self.class}:#{self.object_id}> #{self.class.object_id}")
      self
    end
  end

  #
  # The wrap to combined will take an object and return the combined
  # object if it is a combined object.  But for the general case, we
  # just return the object.
  #
  def wrap_with_combined
    if self.respond_to? :to_combined
      raise "Object#unwrap_to_cached called with Cached object"
    else
      RAILS_DEFAULT_LOGGER.debug("CMB: wrap Object xxx <#{self.class}:#{self.object_id}> #{self.class.object_id}")
      self
    end
  end
end

class Array
  #
  # For an array, the unwrap will return an array but each element
  # will have been unwrapped.
  #
  def unwrap_to_cached
    RAILS_DEFAULT_LOGGER.debug("CMB: unwrap Array <#{self.class}:#{self.object_id}> #{self.class.object_id}")
    self.map{ |e| e.unwrap_to_cached }
  end

  #
  # For an array, the wrap will return an array but each element will
  # have been wrapped.
  #
  def wrap_with_combined
    RAILS_DEFAULT_LOGGER.debug("CMB: wrap Array <#{self.class}:#{self.object_id}> #{self.class.object_id}")
    self.map{ |e| e.wrap_with_combined }
  end
end

class Hash
  #
  # Last, for Hash, the unwrap will return a hash with each value
  # unwrapped.
  #
  def unwrap_to_cached
    RAILS_DEFAULT_LOGGER.debug("CMB: unwrap Hash <#{self.class}:#{self.object_id}> #{self.class.object_id}")
    self.inject({ }) { |o, a| o[a[0]] = a[1].unwrap_to_cached; o }
  end

  #
  # Last, for Hash, the wrap will return a hash with each value
  # wrapped.
  #
  def wrap_with_combined
    RAILS_DEFAULT_LOGGER.debug("CMB: wrap Hash <#{self.class}:#{self.object_id}> #{self.class.object_id}")
    self.inject({ }) { |o, a| o[a[0]] = a[1].wrap_with_combined; o }
  end
end

###  module ActiveRecord
###    module Associations
###      class AssociationCollection < AssociationProxy #:nodoc:
###        #
###        # For an array, the unwrap will return an array but each element
###        # will have been unwrapped.
###        #
###        def unwrap_to_cached
###          RAILS_DEFAULT_LOGGER.debug("CMB: unwrap Association <#{self.class}:#{self.object_id}> #{self.class.object_id}")
###          self.map{ |e| e.unwrap_to_cached }
###        end
###        
###        #
###        # For an array, the wrap will return an array but each element will
###        # have been wrapped.
###        #
###        def wrap_with_combined
###          RAILS_DEFAULT_LOGGER.debug("CMB: wrap Association <#{self.class}:#{self.object_id}> #{self.class.object_id}")
###          self.map{ |e| e.wrap_with_combined }
###        end
###      end
###    end
###  end
###  
###  module ActiveRecord
###    module Associations
###      class BelongsToAssociation < AssociationProxy #:nodoc:
###        #
###        # The unwrap to cached will take an object and return the cached
###        # object if it is a combined object.  But for the general case, we
###        # just return the object.
###        #
###        def unwrap_to_cached
###          if self.respond_to? :cached
###            RAILS_DEFAULT_LOGGER.debug("CMB: unwrap Combined BelongsTo <#{self.class}:#{self.object_id}> #{self.class.object_id}")
###            self.cached
###          else
###            RAILS_DEFAULT_LOGGER.debug("CMB: unwrap BelongsTo <#{self.class}:#{self.object_id}> #{self.class.object_id}")
###            self
###          end
###        end
###        
###        #
###        # The wrap to combined will take an object and return the combined
###        # object if it is a combined object.  But for the general case, we
###        # just return the object.
###        #
###        def wrap_with_combined
###          if self.respond_to? :to_combined
###            RAILS_DEFAULT_LOGGER.debug("CMB: wrap Cached BelongsTo <#{self.class}:#{self.object_id}> #{self.class.object_id}")
###            self.to_combined
###          else
###            RAILS_DEFAULT_LOGGER.debug("CMB: wrap BelongsTo xxx <#{self.class}:#{self.object_id}> #{self.class.object_id}")
###            self
###          end
###        end
###      end
###    end
###  end
###  
###  module WrapWithCombine
###    def WrapWithCombine.included(mod)
###      debugger
###    end
###    def included(mod)
###      debugger
###    end
###    def WrapWithCombine.extend_object(mod)
###      debugger
###    end
###    def extend_object(mod)
###      debugger
###    end
###  end

#
# AssociationProxy removes all of the methods it sees when it is
# created (except for a special few).  This causes all calls to be
# sent to the method_missing routine which are then sent to the
# proxied object.  An example of a proxied object is the 'queue' in
# FavoriteQueue.
#
# Since this file loads after all this happens, the wrap and unwrap
# methods are in AssociationProxy's direct list via the inheritance
# path to Object.  But we don't want that.  We want those methods
# proxied as well.  So, we undef them here.
#
module ActiveRecord
  module Associations
    class AssociationProxy #:nodoc:
      undef_method :wrap_with_combined
      undef_method :unwrap_to_cached
    end
  end
end

puts "wrap loaded"
