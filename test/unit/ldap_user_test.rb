# -*- coding: utf-8 -*-

require 'test_helper'

# This test assumes that you can connect to the ibm bluepages LDAP
# server.  It also assumes particular people exist so the test will
# need to be changed over time.
class LdapUserTest < ActiveSupport::TestCase
  include LdapConstants

  test "authenticate with good email and password" do
    assert_nothing_raised do
      ret = LdapUser.authenticate_from_email(GOOD_EMAIL, GOOD_PASSWORD)
      assert_equal true, ret, "failed but password may be old"
    end
  end

  test "authenticate with good email but bad password fails" do
    assert_nothing_raised do
      ret = LdapUser.authenticate_from_email(GOOD_EMAIL, "badpassword")
      assert_not_equal true, ret, "bad password should fail"
    end
  end

  test "get with bad uid fails" do
    assert_nothing_raised do
      assert_equal nil, LdapUser.find(:first, BAD_UID)
    end
  end

  test "get via contractor uid works" do
    assert_nothing_raised do
      l = LdapUser.find(:first, GOOD_CONTRACTOR_UID)
      assert_not_nil l
      assert_equal GOOD_DEPT, l.dept
      mgr = l.mgr
      assert_not_nil mgr
      assert_not_nil mgr.dept   # we don't know what it is :-(
      d = l.deptmnt
      assert_not_nil d
      assert_equal GOOD_DEPT, d.dept
    end
  end

  test "get via regular uid works" do
    assert_nothing_raised do
      l = LdapUser.find(:first, GOOD_REGULAR_UID)
      assert_not_nil l
      assert_equal GOOD_DEPT, l.dept
      mgr = l.mgr
      assert_not_nil mgr
      assert_not_nil mgr.dept   # we don't know what it is :-(
      d = l.deptmnt
      assert_not_nil d
      assert_equal GOOD_DEPT, d.dept
    end
  end

  test "get via manager uid works" do
    assert_nothing_raised do
      m = LdapUser.find(:first, GOOD_MANAGER_UID)
      assert_not_nil m
      assert_equal 'Y', m.ismanager
      # Try and sanity check manages function...
      list = m.manages
      assert_equal(true,
                   ( 15 .. 30 ) === list.length,
                   "Manages is expected to return a list of 15 to 30")

      assert_equal(true,
                   list.any? { |p| p.uid == GOOD_CONTRACTOR_UID },
                   "List of managed people is expected to contain GOOD_CONTRACTOR_ID")
      assert_equal(true,
                   list.any? { |p| p.uid == GOOD_REGULAR_UID },
                   "List of managed people is expected to contain GOOD_REGULAR_ID")
      assert_equal(false,
                   list.any? { |p| p.uid == GOOD_MANAGER_UID },
                   "Members of department is expected to *not* contain GOOD_MANAGER_UID")
    end
  end
end
