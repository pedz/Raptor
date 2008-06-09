class Retuser < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :retid
  validates_presence_of :password
  attr_accessor :password_confirmation
  validates_confirmation_of :password

  def to_param
    self.retid
  end
end
