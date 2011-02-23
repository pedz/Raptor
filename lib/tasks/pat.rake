# -*- coding: utf-8 -*-

desc "task to move Customer_list.txt into database"
task :add_pat do
  Rake::Task["rake:environment"].invoke
  top = File.dirname(__FILE__) + "/../.."
  list = []
  File.open(top + "/public/Customer_list.txt") do |f|
    f.set_encoding('utf-8')
    f.each_line do |l|
      l.chomp!
      if md = /^(\S+)\s+(.*)/.match(l)
        id = md[1]
        name = md[2]
        # If the length is less than the full 7 characters, I assume
        # for now that the leading characters should be 0s AND I also
        # assume that it is a pure numeric id.  That appears to be the
        # case for now.
	if id.length < 7
          id = "%07d" % id.to_i
        end
        list << "'#{id}'"
      end
    end
  end
  Cached::Customer.transaction do
    Cached::Customer.update_all("pat = false")
    Cached::Customer.update_all("pat = true", "customer_number in ( #{list.join(', ')} )")
  end
end
