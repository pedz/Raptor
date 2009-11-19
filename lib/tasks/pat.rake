task :add_pat do
  Rake::Task["rake:environment"].invoke
  top = File.dirname(__FILE__) + "/../.."
  list = []
  File.open(top + "/public/Customer_list.txt") do |f|
    f.each_line do |l|
      l.chomp!
      if md = /^([^ ]+) +(.*)/.match(l)
        id = md[1]
        name = md[2]
        list << "'#{id}'"
      end
    end
  end
  Cached::Customer.transaction do
    Cached::Customer.update_all("pat = false")
    Cached::Customer.update_all("pat = ture", "customer_number in #{list.join(', ')}")
  end
end
