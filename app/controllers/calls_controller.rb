# -*- coding: utf-8 -*-
#
# Controller for the "calls" path.  The routes for this controller
# are:
#
#    map.calls("calls/:group/:levels/:filter/:view",
#              :controller => 'calls',
#              :action => 'index',
#              :group => /[^\/]+/)
#  
#    map.calls("calls/:group/:levels/:filter",
#              :controller => 'calls',
#              :action => 'index',
#              :group => /[^\/]+/)
#  
#    map.calls("calls/:group/:levels",
#              :controller => 'calls',
#              :action => 'index',
#              :group => /[^\/]+/)
#  
#    map.calls("calls/:group",
#              :controller => 'calls',
#              :action => 'index',
#              :group => /[^\/]+/)
#  
#    map.calls("calls",
#              :controller => 'calls',
#              :action => 'index')
#  
#
# This is a subclass of RetainController because we want to
# verify that the user has a valid retain id because he is going to
# cause background fetches to start and we want some hope that they
# will work.  We also don't want people without Retain ids viewing the
# data.  But, this controller does not use any of the Combined or
# Retain models.
#
class CallsController < Retain::RetainController
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
    @redirect = false
    @argument_array = []
    @redirect_array = []
    @options = { }
    argument_types = ArgumentType.all(:order => "position").each do |argument_type|
      # First see if we have an argument in this position.  Rails will
      # give it the name we want based upon what is in routes.rb
      if (v = params[argument_type.name]).nil?
        v = set_default(argument_type)
      end

      while (e = Entity.find_by_name(v)).nil?
        d = set_default(argument_type)
        if v == d
          raise "Default not found"
        end
        flash[:error] = "#{v} not known"
        v = d
      end
        
      # Redirect if type is not in the right place
      @redirect = true if e.argument_type.name != argument_type.name
      
      # See if this is a duplicate argument of this type
      unless @redirect_array[e.argument_type.position].nil?
        flash[:warning] = ("Multiple arguments specified for #{e.argument_type.name}"
                           " (position #{e.argument_type.position})")
        
      end
      @argument_array[e.argument_type.position] = e
      @redirect_array[e.argument_type.position] = v
      @options[e.argument_type.name] = v
    end

    if @redirect
      @options.delete('subject')
      redirect_to(@options)
    else
      @widgets = View.find_by_name(@options["view"]).widgets.map { |widget| "widgets/#{widget.name}"}
      render
    end
  end

  private

  def set_default(argument_type)
    @redirect = true unless argument_type.position == 0
    unless (arg0 = @argument_array[0]).nil? # unless argument position 0 has not been set
      raise "First argument must be a Name" unless arg0.base_type == 'Name'
      item = arg0.item
      argument_default = item.argument_defaults.find_by_argument_position(argument_type.position)
      return argument_default.default unless argument_default.nil?
    end

    v = argument_type.default
    # I hate special cases...
    v = application_user.current_retain_id.retid if v == "current_retuser_id"
    return v
  end
end
