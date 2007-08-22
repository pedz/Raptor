class RetainUser < ActiveRecord::Base
  has_one :user
  # has_many :retain_queues, :through => :user
  validates_presence_of :retid
  validates_presence_of :password
  attr_accessor :password_confirmation
  validates_confirmation_of :password
end
