# -*- coding: utf-8 -*-

class FeedbackNote < ActiveRecord::Base
  ##
  # :attr: id
  # The key to the table.

  ##
  # :attr: feedback_id
  # An id that refers to the feedbacks table.

  ##
  # :attr: note
  # The actual text for the feedback.

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

  ##
  # :attr: feedback
  # A belongs_to association to the Feedback that this note belongs
  # to.
  belongs_to :feedback
end
