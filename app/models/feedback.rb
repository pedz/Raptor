class Feedback < ActiveRecord::Base
  has_many :feedback_notes

  FEEDBACK_STATES = [ 'Opened', 'Closed', 'Walkabout' ].freeze
  FEEDBACK_TYPES  = [ 'Suggestion', 'Defect', 'Rant' ].freeze

  def pstate
    FEEDBACK_STATES[state]
  end

  def ptype
    FEEDBACK_TYPES[ftype]
  end
end
