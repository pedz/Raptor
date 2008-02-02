
require 'cached/base'

class Array
  #
  # For an array, the wrap will return an array but each element will
  # have been wrapped.
  #
  def wrap_with_combined
    RAILS_DEFAULT_LOGGER.debug("CMB: wrap array <#{self.class}:#{self.object_id}>")
    self.map{ |e| e.wrap_with_combined }
  end
end

class Hash
  #
  # Last, for Hash, the wrap will return a hash with each value
  # wrapped.
  #
  def wrap_with_combined
    RAILS_DEFAULT_LOGGER.debug("CMB: wrap hash <#{self.class}:#{self.object_id}>")
    self.inject({ }) { |o, a| o[a[0]] = a[1].wrap_with_combined; o }
  end
end
