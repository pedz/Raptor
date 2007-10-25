class Feedback < ActiveRecord::Base
  has_many :feedback_notes

  FEEDBACK_STATES = [ 'Opened', 'Closed', 'Walkabout' ]
  FEEDBACK_STATES.freeze
  FEEDBACK_TYPES  = [ 'Suggestion', 'Defect', 'Rant' ]
  FEEDBACK_TYPES.freeze
end
