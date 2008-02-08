module Retain
  class QueueInfo < ActiveRecord::Base
    belongs_to :queue, :class_name => "Cached::Queue"
    belongs_to :owner, :class_name => "Cached::Registration"
  end
end
