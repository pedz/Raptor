#
# Note that this is *not* a subclass of RetainController.  This will
# work entirely from cached data and trigger updates to that cached
# data via asynchronous updates.
#
class CallsController < ApplicationController
  # Called with four optional arguments:
  #
  #   1 :group Specifies a group of queues.  This may be one of:
  #
  #     1 A group name which may be specialized such as a team or
  #       department or it may be just a group defined by a user.
  #
  #     2 A user id which will denote the user's personal queue.  A
  #       user id is a persons intranet id or what I prefer to call
  #       the Bluepages ldap_id.
  #
  #     3 A retain id which will denote the user's favorite queues.
  #       While this is a bit weird it provies a way to bridge from
  #       the existing favorite queues concept to the new concepts.
  #       This will be the default if no other name that is a group is
  #       specified.
  #
  #   2 :level specifies how deep in the nesting levels to present to
  #     the user.  Please see Nesting and Container for more
  #     information on what these nesting levels are.  The level will
  #     be a Name that will have one Condition as a has_one
  #     assotiation.
  #
  #   3 :filter specifies Filter which is a way to select only a
  #     subset of the calls on the selected queues.  The default will
  #     be "all" which will be no filter.  Perhaps I should call this
  #     "none".  Examples may be "hot" to select only the calls / pmrs
  #     labeled as hot or "pat" to select calls or pmrs for PAT
  #     customers.
  #
  #   4 :view specifies a View which is intended to be thought of as a
  #     way to "view the data".  It can be thought of as a page layout
  #     or a collection of elements that will be displayed.  The
  #     thought is that worker bees will want a different set of
  #     fields and items on their page then team leads or managers.
  #
  # All four parameters are optional so the names must be unique
  # amoung a union of all potential hits.  e.g. if "ptcpk" is a team,
  # then it can not be the name of a group, level, filter, view,
  # user's ldap id, or a retain id.
  #
  # If some of the parameters are missing or if they are given out of
  # order, a redirect will occur to the properly formatted URL.  The
  # thought here to help any and all caching that may be done in the
  # browser or intermediate servers.  The intention is that these will
  # never be altered by state.  So, user 1 will see exactly the same
  # data as user 2 for a given URL.
  def index
    redirect = false
    redirect_array = []
    options = { }
    argument_types = ArgumentTypes.all(:order => "position").each do |argument_type|
      # First see if we have an argument in this position.  Rails will
      # give it the name we want based upon what is in routes.rb
      if (v = params[argument_type.name]).nil?
        redirect = true
        v = argument_type.default
        # I hate special cases...
        v = application_user.current_retuser_id if v == "current_retuser_id"
      end

      # Now see if this argument is the type it is suppose to be


    end
  end
end
