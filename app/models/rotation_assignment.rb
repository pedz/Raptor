class RotationAssignment < ActiveRecord::Base
  ##
  # :attr: rotation_group
  # A belongs_to association with the RotationGroup the RotationAssignment belongs to
  belongs_to :rotation_group

  ##
  # :attr: rotation_types
  # A has_many association through the rotation_group belongs to for
  # the RotationTypes that this RotationAssignment may have.
  has_many :rotation_types, :through => :rotation_group

  ##
  # :attr: rotation_type
  # A belongs_to association to the RotationType chosen for this
  # particular RotationAssignment
  belongs_to :rotation_type
end
