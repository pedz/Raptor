# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

#
# This is a class that fetches LDAP entries from Bluepages of type
# ibmPerson.  The default key is uid which is the "employee number".
# Thus the following would find me:
#
#     LdapUser.find('C-5UEV897')
#
# The ActiveLdap::find is very powerful and versatile.  To fine me via
# mail intranet id:
#
#     LdapUser.find(:first, :attribute => 'mail', :value => 'pedzan@us.ibm.com')
#
# Or, to find everyone in a department:
#
#    LdapUser.find(:all, :attribute => 'dept', :value => '5IEA')
#
# Note that these classes are called LdapXxxx pretending to be general
# LDAP classes but really they are Bluepages specific since they
# depend upon the structure of Bluepages.
class LdapUser < ActiveLdap::Base
  ldap_mapping(:dn_attribute => 'uid',
               :prefix => 'ou=bluepages',
               :classes => [ 'ibmPerson' ])

  ##
  # :attr: mgr
  # A belongs_to association to an LdapUser for the user's manager.
  belongs_to :mgr,     :class => 'LdapUser', :foreign_key => 'manager', :primary_key => 'dn'

  ##
  # :attr: deptmnt
  # (I have to be careful not to collide with existing Bluepages
  # attributes -- thus the funky name).  A belongs_to association to
  # an LdapDept for the user's department.
  belongs_to :deptmnt, :class => 'LdapDept', :foreign_key => 'dept',    :primary_key => 'dept'

  ##
  # :attr: manages
  # A has_many association returning the LdapUser entries for this user.
  has_many   :manages, :class => 'LdapUser', :foreign_key => 'manager', :primary_key => 'dn'

  ##
  # Authenticate the intranet email address and password against
  # Bluepages.
  def self.authenticate_from_email(email, password)
    return nil unless (u = find(:first, :attribute => 'mail', :value => email, :attributes => [ 'dn']))
    begin
      # dn = u.dn.to_s.gsub(/\+/, "\\\\+")
      dn = u.dn.to_s
      logger.info("authenticate_from_email #{email} => #{dn}")
      u.connection.rebind(:allow_anonymous => false, :password => password, :bind_dn => dn)
    rescue => e
      # logger.debug("authenticate_from_email denied #{e.class} #{e.message}")
      nil
    end
  end

  # A silly method to return my entry used for testing and such.  The
  # 'q' is for 'quick'
  def self.q
    find(:first, :attribute => 'mail', :value => 'pedzan@us.ibm.com')
  end
end
