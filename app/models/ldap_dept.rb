# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# A Bluepages Department.
class LdapDept < ActiveLdap::Base
  ldap_mapping(:dn_attribute => 'dept',
               :prefix => 'ou=bluepages',
               :classes => ['top', 'ibmDepartment'])
  ##
  # :attr: members
  # A has_many association returning the LdapUser entries for the department.
  # :nodoc:
  # Contractors have 'department' which is a dn back to an
  # ibmDepartment.  Regulars have divDept which is a dn back to a
  # "ibmdivdept".  So, we can't use a dn for the foreign key
  has_many :members, :class => 'LdapUser', :foreign_key => 'dept', :primary_key => 'dept'
end
