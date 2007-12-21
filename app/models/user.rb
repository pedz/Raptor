class User < ActiveRecord::Base
  attr_protected :ldap_id, :retain_user_id, :admin
  has_many :retusers
  has_many :retain_favorite_queues, :class_name => "Retain::FavoriteQueue"
end
