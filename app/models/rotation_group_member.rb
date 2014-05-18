class RotationGroupMember < ActiveRecord::Base
  validates_uniqueness_of :name, :scope => :rotation_group_id
  validates_uniqueness_of :user_id, :scope => :rotation_group_id
  validates_presence_of :name, :user_id
  
  ##
  # :attr: rotation_group
  # A belongs_to association to the owning RotationGroup
  belongs_to :rotation_group
  
  ##
  # :attr: user
  # A belongs_to association to the user
  belongs_to :user
end
