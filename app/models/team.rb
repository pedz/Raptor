# -*- coding: utf-8 -*-

# This model represents a team inside a particular organization.
#
#
class Team < ActiveRecord::Base
  ##
  # :attr: name
  # name of the team

  ##
  # :attr: dept
  # The department the team is in.  Currently, there is no way to
  # represent teams split between departments.

  ##
  # :attr: team_queues
  # has_many list of incoming TeamQueue for the team.
  has_many :team_queues
end
