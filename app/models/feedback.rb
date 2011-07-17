# -*- coding: utf-8 -*-

# A model for feedback messages from users.
class Feedback < ActiveRecord::Base
  ##
  # :attr: id
  # The key to the table

  ##
  # :attr: abstract
  # The abstract to the feedback

  ##
  # :attr: priority
  # The priority of the feedback.

  ##
  # :attr: ftype
  # An ordinal that refers to Suggestion (0), Defect (1), or Rant (2)

  ##
  # :attr: state
  # An ordinal for the  state of the feedback: Opened (0), Closed (1),
  # or Walkabout (1)

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

  ##
  # :attr: feedback_notes
  # A has_many association of the FeedbackNote entries that refer to
  # this Feedback.
  has_many :feedback_notes

  FEEDBACK_STATES = [ 'Opened', 'Closed', 'Walkabout' ].freeze
  FEEDBACK_TYPES  = [ 'Suggestion', 'Defect', 'Rant' ].freeze

  # Returns the text for the state of the feedback.
  def pstate
    FEEDBACK_STATES[state]
  end

  ## Returns teh text for the type of the feedback.
  def ptype
    FEEDBACK_TYPES[ftype]
  end
end
