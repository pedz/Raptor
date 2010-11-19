# -*- coding: utf-8 -*-

# = User
#
# This model represents a user of Raptor and is looked up by the LDAP
# id which is assumed to be the user name given via basic http
# authentication.
#
# == Fields
#
# <em>id - integer</em>::
#   The key field for the table.
#   
# <em>ldap_id - string</em>::
#   The user name given to the http basic authentication form and
#   should match the Bluepages email field which most people call
#   their intranet id.
#   
# <em>admin - boolean</em>::
#   True makes this user an administrator for Raptor.
#
# <em>created_at - timestamp</em>::
#   Usual Rails created at timestamp.
#
# <em>updated_at - timestamp</em>::
#   Usual Rails updated at timestamp.
#
# <em>ftp_host - string</em>::
#   Not used right not but was going to be used so the user could
#   click on a testcase string and have the testcase sent via ftp to
#   the host and directory the user specified by these variables.
#   
# <em>ftp_login - string</em>::
#   Not used.  user login for ftp system not yet implemented.
#
# <em>ftp_pass - string</em>::
#   Not used.  user password for ftp system not yet implemented.
#
# <em>ftp_basedir - string</em>::
#   Not used.  basedir of where testcases would be placed in the ftp
#   system not yet implemented.
#
# <em>current_retuser_id - integer</em>::
#   Foreign key to the retuser table.  Nulls are allowed here -- one
#   of the few places where that is true.  The reason is because the
#   user model is created automatically and we will not have a way to
#   create any retusers.  I don't really want to change how that
#   process works.
#

class User < ActiveRecord::Base
  attr_protected :ldap_id, :retain_user_id, :admin
  has_many :retusers, :include => [ :software_node, :hardware_node ]
  belongs_to :current_retain_id, :class_name => "Retuser", :foreign_key => "current_retuser_id"
  has_many :favorite_queues, :through => :current_retain_id, :order => :sort_column

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
end
