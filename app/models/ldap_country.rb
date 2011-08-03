# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a class that is not used.  I wrote this while trying to
# understand how IBM bluepages and LDAP works.  If you are curious, it
# finds "ibmCountry" objects given something like:
#
# LdapCountry.find(:first, "us")
#
# Problem is I can't find any use for it at all.
#
class LdapCountry < ActiveLdap::Base
  ldap_mapping(:dn_attribute => 'c',
               :prefix => 'ou=bluepages',
               :classes => [ 'top', 'ibmCC' ])
end
