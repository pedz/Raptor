# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

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
