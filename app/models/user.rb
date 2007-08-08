class User < ActiveRecord::Base
  belongs_to :retain_user
  has_many   :retain_queues
end
