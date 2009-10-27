# -*- coding: utf-8 -*-

#
# A group of methods added to each subclass of Retain::Base,
# Cached::Base, and Combined::Base that return each other's class
# names and constants.
#
module ClassNameUtils    
  # Returns the Cached class (as a constant) for this class
  def cached_class
    @cached_class ||= cached_class_name.constantize
  end
  
  # Returns the Cached class name (as a string) for this class
  def cached_class_name
    @cached_class_name ||= "Cached::" + my_class_name.to_s.sub(/.*::/, "")
  end
  
  # Returns the Combined class (as a constant) for this class
  def combined_class
    @combined_class ||= combined_class_name.constantize
  end
  
  # Returns the Combined class name (as a string) for this class
  def combined_class_name
    @combined_class_name ||= "Combined::" + my_class_name.to_s.sub(/.*::/, "")
  end
  
  # Returns the Retain class (as a constant) for this class
  def retain_class
    @retain_class ||= retain_class_name.constantize
  end
  
  # Returns the Retain class name (as a string) for this class
  def retain_class_name
    @retain_class_name ||= "Retain::" + my_class_name.to_s.sub(/.*::/, "")
  end

  def my_class_name
    if self.is_a? Class
      self.to_s
    else
      self.class.to_s
    end
  end
end
