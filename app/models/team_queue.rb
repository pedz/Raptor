# -*- coding: utf-8 -*-

# This model represents a one to many mapping between a team and its
# incoming queue.
class TeamQueue < ActiveRecord::Base
  ##
  # :attr: team
  # The Team that the queue belongs to
  belongs_to :team

  ##
  # :attr: cached_queue
  # The Cached::Queue that is owned by team.  A database contraint
  # requires that a queue can be in the table at most one time.  This
  # forces an incoming queue to be owned by at most one team.
  belongs_to :cached_queue
end
