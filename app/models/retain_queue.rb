class RetainQueue < ActiveRecord::Base
  belongs_to :user
  # has_many :retain_users, :through => :user
end
