
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
      # RAILS_DEFAULT_LOGGER.debug("CMB: unwrap Object <#{self.class}:#{self.object_id}> #{self.class.object_id}")
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
      # RAILS_DEFAULT_LOGGER.debug("CMB: wrap Object <#{self.class}:#{self.object_id}> #{self.class.object_id}")
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
    # RAILS_DEFAULT_LOGGER.debug("CMB: unwrap Array <#{self.class}:#{self.object_id}> #{self.class.object_id}")
    self.map{ |e| e.unwrap_to_cached }
  end

  #
  # For an array, the wrap will return an array but each element will
  # have been wrapped.
  #
  def wrap_with_combined
    # RAILS_DEFAULT_LOGGER.debug("CMB: wrap Array <#{self.class}:#{self.object_id}> #{self.class.object_id}")
    self.map{ |e| e.wrap_with_combined }
  end
end

class Hash
  #
  # Last, for Hash, the unwrap will return a hash with each value
  # unwrapped.
  #
  def unwrap_to_cached
    # RAILS_DEFAULT_LOGGER.debug("CMB: unwrap Hash <#{self.class}:#{self.object_id}> #{self.class.object_id}")
    self.inject({ }) { |o, a| o[a[0]] = a[1].unwrap_to_cached; o }
  end

  #
  # Last, for Hash, the wrap will return a hash with each value
  # wrapped.
  #
  def wrap_with_combined
    # RAILS_DEFAULT_LOGGER.debug("CMB: wrap Hash <#{self.class}:#{self.object_id}> #{self.class.object_id}")
    self.inject({ }) { |o, a| o[a[0]] = a[1].wrap_with_combined; o }
  end
end

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
# But, it turns out that we need to wrap association proxy objects
# like we wrap active record objects.
#
module ActiveRecord
  module Associations
    class AssociationProxy #:nodoc:
      undef_method :unwrap_to_cached
      # undef_method :wrap_with_combined

      # For now, we are going to wrap a proxy object if it is
      # pretending to be an array.  Otherwise, we ask if it responds
      # to :to_combined.  If it does, we call it.  Otherwise, we just
      # return self.
      #
      # Its not clear if, in the first case of an object acting like
      # an Array if we need to wrap each of the elements.  Right now,
      # we are not going to do that.  We'll see how that goes.
      #
      # Oh... the reason for not wrapping single objects is because it
      # defeats methods specific to a Combined class.
      #
      def wrap_with_combined
        if self.kind_of? Array
          # RAILS_DEFAULT_LOGGER.debug("CMB: wrap AssociationProxy <#{self.class}:#{self.object_id}> #{self.class.object_id}")
          Combined::AssociationProxy.new(self)
        elsif self.respond_to? :to_combined
          self.to_combined
        else
          self
        end
      end
    end
  end
end
