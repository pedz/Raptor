# -*- coding: utf-8 -*-

# === Raptor's Retain User Model
#
# 
class Retuser < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.

  ##
  # :attr: user_id
  # The Integer id of the User that the Retuser belongs to.

  ##
  # :attr: password
  # A String that has the Retain user's password.
  validates_presence_of :password
  attr_accessor :password_confirmation
  validates_confirmation_of :password

  ##
  # :attr: failed
  # A Boolean that is set to true when a login attempt fails.  This
  # flag must be manually turned back off.  This is to prevent Raptor
  # from trying with an incorrect password three times and locking the
  # user out of his account.

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

  ##
  # :attr: logon_return
  # The Integer "return" code Retain return from the failed login
  # attempt.  This field is not reset to 0 on a successful login.

  ##
  # :attr: logon_reason
  # The Integer "reason" code Retain returned on the failed login
  # attempt.  This field is not reset to 0 on a successful login.

  ##
  # :attr: apptest
  # A Boolean flag that is true if this Retuser is to be used with the
  # APPTEST part of Retain.

  ##
  # :attr: software_node_id
  # The Integer id of the RetainNodeSelector used to fetch software
  # elements like PMS entries.  This is set by the user via the
  # retuser setup pages.


  ##
  # :attr: hardware_node_id
  # The Integer id of the RetainNodeSelector used to fetch hardware
  # elements like PMH entries.  This is set by the user via the
  # retuser setup pages.

  ##
  # :attr: user
  # A belongs_to association to a User
  belongs_to :user

  ##
  # :attr: retid
  # A String that has the Retain user's id.
  validates_presence_of :retid

  ##
  # :attr: software_name
  # A belongs_to association to a RetainNodeSelector that is used to
  # fetch software Retain elements like a PMR.
  belongs_to(:software_node,
             :class_name => "RetainNodeSelector",
             :foreign_key => :software_node_id,
             :include => :retain_node)
  ##
  # :attr: hardware_node
  # A belongs_to association to a RetainNodeSelector that is used to
  # fetch hardware Retain elements ike a PMH or a hardware queue.
  belongs_to(:hardware_node,
             :class_name => "RetainNodeSelector",
             :foreign_key => :hardware_node_id,
             :include => :retain_node)

  ##
  # :attr: favorite_queues
  # A has_many association to FavoriteQueue for the favorite queues
  # associated with this Retuser id.
  has_many :favorite_queues, :include => :queue, :order => :sort_column
  
  ##
  # :attr: containments
  # Container A has_many association returning the Container elements
  # that have this item as the container.
  has_many :containments, :as => :container
  
  ##
  # :attr: nestings
  # Container A has_many association returning the Container elements
  # that have this item as the container.
  has_many :nestings, :as => :container

  ##
  # :attr: entity
  # A has_one association to an Entity.
  has_one :entity, :class_name => "Entity", :as => :item
end
