# -*- coding: utf-8 -*-

require 'test_helper'

Combined.send(:remove_const, "DB_ONLY")
Combined::DB_ONLY = true

class CachedCustomersTest < ActiveSupport::TestCase
  # These tests were initial here to try and get a faster
  # implementation of calculating business days and business hours.
  # But I finally gave up and use "Jim's method" which is a slow
  # interitive process.  If I ever get the desire to try this again,
  # these test will be useful.  So I'm going to leave them here but
  # commented out since right now "business_days" just calls
  # "jims_business days"

  # FMT = "%Y/%m/%d %H:%M:%S %Z"
  # def test_business_days
  #   cust = @cerner_customer
  #   # assert_equal cust.business_days(DateTime.strptime("2008/09/22 08:00:00 CST", FMT), 1), DateTime.strptime("2008/09/24 08:00:00 CST", FMT), "foo dog"
  #   t = DateTime.strptime("2008/09/22 08:01:00 CST", FMT)
  #   (0 .. 24*7).each { |i|
  #     # puts "#{t} => #{cust.business_days(t, 1)}, #{cust.jims_business_days(t, 1)}"
  #     assert_equal cust.jims_business_days(t, 1), cust.business_days(t, 1), "for #{t.strftime("%a, %d %b %Y %H:%M:%S %Z")} plus a day"
  #     assert_equal cust.jims_business_days(t, 5), cust.business_days(t, 5), "for #{t.strftime("%a, %d %b %Y %H:%M:%S %Z")} plus five days"
  #     t += 1.hour
  #   }
  # end

  # def test_business_hours
  #   cust = @cerner_customer
  #   # assert_equal cust.business_days(DateTime.strptime("2008/09/22 08:00:00 CST", FMT), 1), DateTime.strptime("2008/09/24 08:00:00 CST", FMT), "foo dog"
  #   t = DateTime.strptime("2008/09/22 08:01:00 CST", FMT)
  #   (0 .. 24*7).each { |i|
  #     # puts "#{t} => #{cust.business_days(t, 1)}, #{cust.jims_business_days(t, 1)}"
  #     assert_equal cust.jims_business_hours(t, 1), cust.business_hours(t, 1), "for #{t.strftime("%a, %d %b %Y %H:%M:%S %Z")} plus an hour"
  #     assert_equal cust.jims_business_hours(t, 8), cust.business_hours(t, 8), "for #{t.strftime("%a, %d %b %Y %H:%M:%S %Z")} plus eight hours"
  #     t += 1.hour
  #   }
  # end
end
