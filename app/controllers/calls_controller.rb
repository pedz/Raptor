class CallsController < ApplicationController
  # Called with three optional arguments:
  #   * :group Specifies a group of queues.  This can be:
  #     1 a team name which denotes the team queues for that team.
  #     2 a group name created by any user of the system.
  #     3 a user's retain id which denotes that users's list of
  #       favorite queues.  This is the default.
  #   * :view Specifies a name of a view.  The default view is called
  #     "default" (hence the name).
  #   * :subselect Specifies a way to select only a subset of the
  #     calls on the selected queues.  The default is "all".  It is
  #     TBD as to how subselects are created and managed.
  #
  # Because all three parameters are optional, they names must be
  # unique amount a union of all potential hits.  e.g. if "ptcpk" is a
  # team, then it can not be the name of a group, view, subselect, or
  # a retain id.
  #
  # I suppose the three paramters could be listed in any order but
  # lets not do that right now.
  def index
    
  end
end
