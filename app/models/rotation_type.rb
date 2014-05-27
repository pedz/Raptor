class RotationType < ActiveRecord::Base
  ##
  # :attr: rotation_group
  # A belongs_to association to the owning RotationGroup
  belongs_to :rotation_group
  
  ##
  # :attr: next_type
  # A has_one association to the next rotation_type to execute
  has_one(:next_type, :class_name => 'RotationType', :primary_key => :next_type_id, :foreign_key => :id)

  def unique_name
    "#{rotation_group.name}/#{name}"
  end
end
