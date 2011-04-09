# -*- coding: utf-8 -*-

# This model represents a team inside a particular organization.
#
#
class Team < Name
  ##
  # :attr: name
  # name of the team (via Name parent class)

  ##
  # :attr: owner
  # A belongs_to relation.  Only the owner can modify this
  # entity. (also via Name parent class)

  ##
  # :attr: team_queues
  # has_many list of incoming TeamQueue for the team.
  has_many :team_queues
end
