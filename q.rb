
p = Retain::ConnectionParameters.new(:host => 'sf2.pok.ibm.com', :port => 3381, :signon => '305356', :password => 'COWS105C')
puts "hi 1"
Retain::Logon.instance.set(p)
puts "hi 2"
q = Retain::Queue.new(:queue_name => 'pedz', :center => '165')
puts "hi 3"
recs = q.de32
puts "class for recs is #{recs.class}"
puts "class for recs[0] is #{recs[0].class}"
puts recs[0].call_search_result
