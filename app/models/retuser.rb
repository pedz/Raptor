# -*- coding: utf-8 -*-

# = Retain User
#
# This model belongs to the User model and holds the users retain
# specific login information.
#
# ==Fields
#
# <em>id - integer</em>::
#   The key field for the table.
# <em>user_id - integer</em>::
#   id from the User model this record belongs to.
# <em>retid - character varying</em>::
#   The user's Retain id.
# <em>password - character varying</em>::
#   The user's Retain password.
# <em>failed - boolean</em>::
#   If true, the last access attempt failed and no futher attempts
#   will be made until this flag is turned back off.
# <em>created_at - timestamp without time zone</em>::
#   Timestamp of when record was create.
# <em>updated_at - timestamp without time zone</em>::
#   Timestamp of when record was last update.
# <em>return_value - integer</em>::
#   On the last failure, the return value returned by Retain.
# <em>reason - integer</em>::
#   On the last failure, the reason code returned by Retain.
# <em>host - string</em>::
#   The host the user has selected to use.
# <em>node - string</em>::
#   The node the user has selected to use.
# <em>port - integer</em>::
#   The port the user has selected to use.
# <em>test - boolean</em>::
#   Boolean flag is user is going to a test node.
#
# The host, node, port, and test fields have some redundant
# information in them.  The retain YAML file is loaded and defines all
# the available nodes and which hosts and ports they correspond to.
# Generally, a node goes to a specific host and port but there can be
# backup or alternative ports and there can also be ports which go to
# the test systems.  The four fields are set by the user from a set of
# choices defined in the retain YAML config file.  
#
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
