# -*- coding: utf-8 -*-

# = Retain User
#
# This model belongs to the User model and holds the users retain
# specific login information.
#
# ==Fields
#
# <em>id - integer</em>:: The key field for the table.
#
# <em>user_id - integer</em>:: id from the User model this record
#   belongs to.
#
# <em>retid - character varying</em>:: The user's Retain id.
#
# <em>password - character varying</em>:: The user's Retain password.
#
# <em>failed - boolean</em>:: If true, the last access attempt failed
#   and no futher attempts will be made until this flag is turned back
#   off.
#
# <em>created_at - timestamp without time zone</em>:: Timestamp of
#   when record was create.
#
# <em>updated_at - timestamp without time zone</em>:: Timestamp of
#   when record was last update.
#
# <em>return_value - integer</em>:: On the last failure, the return
#   value returned by Retain.
#
# <em>reason - integer</em>:: On the last failure, the reason code
#   returned by Retain.
#
# <em>apptest - boolean</em>:: Boolean flag is user is going to an
#   APPTEST node.
#
# <em>software_node_id - boolean</em>:: The node this user will use
#   when fetching software elements like PMRs.
#
# <em>hardware_node_id - boolean</em>:: The node this user will use
#   when fetching hardware elements like PMHs.
#
#
class Retuser < ActiveRecord::Base
  belongs_to :user
  belongs_to(:software_node,
             :class_name => :retain_node_selector,
             :foreign_key => :software_node_id)
  belongs_to(:hardware_node,
             :class_name => :retain_node_selector,
             :foreign_key => :hardware_node_id)

  validates_presence_of :retid
  validates_presence_of :password
  attr_accessor :password_confirmation
  validates_confirmation_of :password

  def to_param
    self.retid
  end
end
