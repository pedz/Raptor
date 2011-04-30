class CallsController < ApplicationController
  # Called with three optional arguments:
  #
  #   * :group Specifies a group of queues.  This may be one of:
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
  #   * :perspective Specifies a way to select only a subset of the
  #     calls on the selected queues.  The default is "all".  It is
  #     TBD as to how perspectives are created and managed.
  #
  #   * :presentation Specifies a name of a presentation.  The default
  #     presentation is called "default" (hence the name).
  #
  # All three parameters are optional so the names must be unique
  # amount a union of all potential hits.  e.g. if "ptcpk" is a team,
  # then it can not be the name of a group, presentation, perspective,
  # user's ldap id, or a retain id.
  #
  # If some of the parameters are missing or if they are given out of
  # order, a redirect will occur to the properly formatted URL.
  def index
    
  end
end
