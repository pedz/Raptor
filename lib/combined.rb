#
# We have three classes, cached, combined, and retain.  The cached
# classes are active record classes.  The retain classes are the
# classes that make requests to retain.  The combined classes are the
# glue that ties these two together.
#
# Each cached subclass (e.g. Cached::Call) has a to_combined method.
# It simply calls new on the appropriate Combined class.
# e.g. to_combined in Cached::Call calls Combined::Call.new(self).
# The initialize method in the Combined classes pocket the argument in
# an instance variable called @cache.
#
# Each Combined class also must define a load method which takes the
# value in @cache and makes the appropriate call to Retain to get the
# rest of the data.
#
# Finally, each Combined calss defines a valid_cache method which
# returns true if the data in the cache can be used.  A return of
# false will cause the load method to be called, fresh data fetched
# from Retain, loaded into the @cache variable and saved to the
# database as well.
#
# The Combined classes each declare what Cached class they mimic.
#

require 'combined/base'
