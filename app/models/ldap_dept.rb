# -*- coding: utf-8 -*-

class LdapDept < ActiveLdap::Base
  ldap_mapping(:dn_attribute => 'dept',
               :prefix => 'ou=bluepages',
               :classes => ['top', 'ibmDepartment'])
  # Contractors have 'department' which is a dn back to an
  # ibmDepartment.  Regulars have divDept which is a dn back to a
  # "ibmdivdept".  So, we can't use a dn for the foreign key
  has_many :members, :class => 'LdapUser', :foreign_key => 'dept', :primary_key => 'dept'

  # def members
  #   LdapUser.find(:all, :attribute => 'dept', :value => dept)
  # end
end
