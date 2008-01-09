module ClassNameUtils    
  def cached_class
    @cached_class ||= cached_class_name.constantize
  end
  
  def cached_class_name
    logger.debug("subclass is #{@subclass}")
    @cached_class_name ||= "Cached::" + @subclass.to_s.sub(/.*::/, "")
  end
  
  def combined_class
    @combined_class ||= combined_class_name.constantize
  end
  
  def combined_class_name
    @combined_class_name ||= "Combined::" + @subclass.to_s.sub(/.*::/, "")
  end
  
  def retain_class
    @retain_class ||= retain_class_name.constantize
  end
  
  def retain_class_name
    @retain_class_name ||= "Retain::" + @subclass.to_s.sub(/.*::/, "")
  end
end
