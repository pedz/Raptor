class RotationAssignment < ActiveRecord::Base
  validates_presence_of :rotation_type
  validates_format_of :pmr, :with => /\A.....,...,...\Z/, :if => :pmr_required

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

  def pmr_required
    logger.debug "rotation type name = #{self.rotation_type ? self.rotation_type.name : "nil" }"
    logger.debug "pmr_required = #{self.rotation_type && self.rotation_type.pmr_required}"
    logger.debug "pmr = '#{self.pmr}' /\A.....,...,...\Z/.match(pmr)}"
    self.rotation_type && self.rotation_type.pmr_required
  end
end
