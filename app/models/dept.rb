# -*- coding: utf-8 -*-

# This model is a subclass of Name so it inherits the owner field.  It
# represents a "Department" in Raptor which is just a type of "Group".
# It might be argued that this model should not exist and Group should
# simply be used.
class Dept < Name
end
