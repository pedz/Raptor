class Conditions < ActiveRecord::Base
  ##
  # :attr: name_id
  # Integer id to a Name

  ##
  # :attr: name
  # A belongs_to association to a Name
  belongs_to :name

  ##
  # :attr: sql
  # A String that is the SQL for the condition
end
