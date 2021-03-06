class RotationType < ActiveRecord::Base
  NO_OP_NAME = 'no-op'
  AUTO_SKIP_NAME = 'auto-skip'

  def self.auto_skip
    @auto_skip ||= self.find_by_name(AUTO_SKIP_NAME)
  end

  def self.no_op
    @no_op ||= self.find_by_name(NO_OP_NAME)
  end

  ##
  # :attr: rotation_group
  # A belongs_to association to the owning RotationGroup
  belongs_to :rotation_group
  
  ##
  # :attr: next_type
  # A has_one association to the next rotation_type to execute
  has_one(:next_type, :class_name => 'RotationType', :primary_key => :next_type_id, :foreign_key => :id)

  ##
  # :attr: rotation_assignments
  # Probably never used but this is a has_many association to all of
  # the RotationAssignments that have been made for this RotationType
  has_many :rotation_assignments

  def unique_name
    "#{rotation_group.name}/#{name}"
  end

  def auto_skip?
    self.id == self.class.auto_skip.id
  end

  def no_op?
    self.id == self.class.no_op.id
  end
end
