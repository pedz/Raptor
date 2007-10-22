class Feedback < ActiveRecord::Base
  has_many :feedback_notes

  FEEDBACK_STATES = [ 'Opened', 'Closed', 'Walkabout' ]
  FEEDBACK_TYPES  = [ 'Suggestion', 'Defect', 'Rant' ]
end
