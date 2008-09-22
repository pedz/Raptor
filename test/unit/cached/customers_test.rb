require File.dirname(__FILE__) + '/../../test_helper'

class CachedCustomersTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  FMT = "%Y/%m/%d %H:%M:%S %Z"
  def test_business_days
    cust = Cached::Customer.find(97)
    # assert_equal cust.business_days(DateTime.strptime("2008/09/22 08:00:00 CST", FMT), 1), DateTime.strptime("2008/09/24 08:00:00 CST", FMT), "foo dog"
    t = DateTime.strptime("2008/09/22 08:01:00 CST", FMT)
    puts ""
    (0 .. 24*7).each { |i|
      # puts "#{t} => #{cust.business_days(t, 1)}, #{cust.jims_business_days(t, 1)}"
      assert_equal cust.jims_business_days(t, 1), cust.business_days(t, 1), "for #{t.strftime("%a, %d %b %Y %H:%M:%S %Z")} plus a day"
      assert_equal cust.jims_business_days(t, 5), cust.business_days(t, 5), "for #{t.strftime("%a, %d %b %Y %H:%M:%S %Z")} plus five days"
      t += 1.hour
    }
  end

  def test_business_hours
    cust = Cached::Customer.find(97)
    # assert_equal cust.business_days(DateTime.strptime("2008/09/22 08:00:00 CST", FMT), 1), DateTime.strptime("2008/09/24 08:00:00 CST", FMT), "foo dog"
    t = DateTime.strptime("2008/09/22 08:01:00 CST", FMT)
    puts ""
    (0 .. 24*7).each { |i|
      # puts "#{t} => #{cust.business_days(t, 1)}, #{cust.jims_business_days(t, 1)}"
      assert_equal cust.jims_business_hours(t, 1), cust.business_hours(t, 1), "for #{t.strftime("%a, %d %b %Y %H:%M:%S %Z")} plus an hour"
      assert_equal cust.jims_business_hours(t, 8), cust.business_hours(t, 8), "for #{t.strftime("%a, %d %b %Y %H:%M:%S %Z")} plus eight hours"
      t += 1.hour
    }
  end
end
