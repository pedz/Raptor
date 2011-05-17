# -*- coding: utf-8 -*-

# This model represents a user of Raptor and is looked up by the LDAP
# id which is assumed to be the user name given via basic http
# authentication.
class User < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.

  ##   
  # :attr: ldap_id
  # A String for user name given to the http basic authentication form
  # and should match the Bluepages email field which most people call
  # their intranet id.
  attr_protected :ldap_id

  ##
  # :attr: admin
  # A Boolean which is true for an administrator for Raptor.
  attr_protected :admin

  ##
  # :attr: created_at
  # Usual Rails created at timestamp.

  ##
  # :attr: updated_at
  # Usual Rails updated at timestamp.

  ##
  # :attr: ftp_host
  # A String which is not used right not but was going to be used so
  # the user could click on a testcase string and have the testcase
  # sent via ftp to the host and directory the user specified by these
  # variables.

  ##
  # :attr: ftp_login
  # A String also not used right now that will be the login id for the ftp_host.

  ##
  # :attr: ftp_pass
  # A String that is not used right now but will be the password to
  # use for the ftp_login at the ftp_host.

  ##
  # :attr: ftp_basedir
  # A String that is not used right now but will be the base directory
  # for the ftp transfers.

  ##
  # :attr: current_retuser_id
  # An Integer foreign key to the retuser table.  Nulls are allowed
  # here -- one of the few places where that is true.  The reason is
  # because the user model is created automatically and we will not
  # have a way to create any retusers.  I don't really want to change
  # how that process works.  I could make a "null retain user" and
  # point to it but that would violate other database constraints.

  ##
  # :attr: retusers
  # A has_many associatio to Retuser.  A User can have more than one
  # Retuser since the same User can work in the real Retain system as
  # well as the APPTEST system.  I can also theorize uses for the same
  # User to want to switch between retain ids.  Currently this is not
  # tested much.
  has_many   :retusers,          :include => [ :software_node, :hardware_node ]

  ##
  # :attr: current_retain_id
  # A belongs_to association to the Retuser that the User is currently
  # using.  This is set by the User via setup pages.
  belongs_to :current_retain_id, :class_name => "Retuser", :foreign_key => "current_retuser_id"

  ##
  # :attr: favorite_queues
  # A has_many association to FavoriteQueue that goes through the
  # current_retain_id association
  has_many   :favorite_queues,   :through => :current_retain_id, :order => :sort_column

  # These don't exist yet....
  # ##
  # # :attr: widgets
  # # A has_many assocation of type Widget that this User owns.
  # has_many   :widgets,           :foreign_key => :owner

  # ##
  # # :attr: views
  # # A has_many association of type View that this User owns.
  # has_many   :views,             :foreign_key => :owner

  ##
  # :attr: relationships
  # A has_many association to Relationship where this User is the item
  # denoted in the relationship
  has_many   :relationships,     :as => :item

  ##
  # :attr: containments
  # A has_many association to Containments returning the elements that
  # have this item as the container.
  has_many :containments, :as => :container

  ##
  # :attr: containment_items
  # A has_many association to Containment that specifies this Name as
  # the container.
  has_many :containment_items, :class_name => "Containment", :as => :item

  ##
  # :attr: nestings
  # A has_many association to Nesting that specifies this Name as the
  # container.
  has_many :nestings, :as => :container

  ##
  # :attr: nesting_items
  # A has_many association to Nesting that specifies this Name as
  # the container.
  has_many :nesting_items, :class_name => "Nesting", :as => :item

  ##
  # :attr: entity
  # A has_one association to an Entity.
  has_one :entity, :class_name => "Entity", :as => :item

  def ldap
    LdapUser::find(:attribute => 'mail', :value => ldap_id)
  end

  def first_name
    @first_name ||= 
      if (given = ldap.givenName).is_a? Array
        given.min { |a, b| a.length <=> b.length }
      else
        given
      end
  end

  # A common method needed since User can be placed as an item within
  # a Relationship
  def item_name
    ldap_id
  end
end
