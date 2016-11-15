class String
  alias orig_concat concat

  def new_concat(s)
    self.orig_concat(s)
  rescue Encoding::CompatibilityError => e
    Rails.logger.error("concat: Almost crashed #{self.encoding} != #{s.encoding}")
    return self.encode('UTF-8').orig_concat(s.encode('UTF-8'))
  rescue => e
    Rails.logger.error("concat: self = #{self.inspect}; self.encoding = #{self.encoding}")
    Rails.logger.error("concat: s = #{s.inspect}; s.encoding = #{s.encoding}")
    raise e
  end
  alias concat new_concat
  alias safe_concat new_concat
end
