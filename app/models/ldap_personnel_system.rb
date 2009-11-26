# -*- coding: utf-8 -*-

# This is also a class like LdapCountry that is not used.  An
# "ibmDepartment" is tucked inside an ibmPersonnelSystem.  But that
# use is rather limited since other contractors seem to be in an
# ibmDepartment.  Regulars are in an ibmdivdept which is tucked inside
# an ibmDiv.
#
class LdapPersonnelSystem < ActiveLdap::Base
  ldap_mapping(:dn_attribute => 'psc',
               :prefix => 'ou=bluepages',
               :classes => ['top', 'ibmPersonnelSystem'])
end
