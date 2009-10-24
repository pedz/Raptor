#
# Bridge code between 1.8.6 and the future.  Adds ord to Fixnum if it
# does not exist AND if String#[] returns a number (like 1.8 did but
# 1.9 does not)
#
# Add ord method to Fixnum for forward compatibility with Ruby 1.9
#
if "a"[0].kind_of? Fixnum
  unless Fixnum.methods.include? :ord
    class Fixnum
      def ord; self; end
    end
  end
end

# Add force_encoding to String.  This may be a mistake but it should
# be fixable later on.
unless String.methods.include? :force_encoding
  class String
    def force_encoding(encoding); self; end
  end
end
