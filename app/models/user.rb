class User < ActiveRecord::Base
  attr_protected :ldap_id, :retain_user_id, :admin
  belongs_to :retain_user
  has_many   :retain_queues
end
