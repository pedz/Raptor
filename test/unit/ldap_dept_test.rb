# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

require 'test_helper'

# This test assumes that you can connect to the ibm bluepages LDAP
# server.  It also assumes particular people exist so the test will
# need to be changed over time.
class LdapUserTest < ActiveSupport::TestCase
  include LdapConstants

  test "get with good dept works" do
    assert_nothing_raised do
      d = LdapDept.find(:first, GOOD_DEPT)
      assert_equal GOOD_DEPT, d.dept
      list = d.members
      assert_equal(true,
                   ( 15 .. 35 ) === list.length,
                   "'members' is expected to return a list of 15 to 30 but returned #{list.length}")

      assert_equal(true,
                   list.any? { |p| p.uid == GOOD_CONTRACTOR_UID },
                   "Members of department is expected to contain GOOD_CONTRACTOR_UID")
      assert_equal(true,
                   list.any? { |p| p.uid == GOOD_REGULAR_UID },
                   "Members of department is expected to contain GOOD_REGULAR_UID")
      assert_equal(false,
                   list.any? { |p| p.uid == GOOD_MANAGER_UID },
                   "Members of department is expected to *not* contain GOOD_MANAGER_UID")
    end
  end
end
