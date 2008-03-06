class User < ActiveRecord::Base
  attr_protected :ldap_id, :retain_user_id, :admin
  has_many :retusers
  has_many :favorite_queues, :class_name => "Cached::FavoriteQueue", :include => :queue
end
