#
# A script to play with searching
#
# (run via script/runner)

module Retain
  class Search2 < Retain::Base
    set_fetch_sdi Pmsu

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end
  end
end

module Retain
  class Search < Retain::Base
    set_fetch_sdi Pmsr

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end
  end
end

retuser = Retuser.find_by_retid('305356')
retain_user_connection_parameters = Retain::ConnectionParameters.new(retuser)
Retain::Logon.instance.set(retain_user_connection_parameters)
search = Retain::Search2.new(retain_user_connection_parameters,
                             :search_argument => 'L165 A11/07/15',
                             :hit_limit => 499)

de32s = search.de32s
puts search.hit_count
puts de32s.length
de32s.each do |de32|
  puts "#{de32.problem},#{de32.branch},#{de32.country} #{de32.alteration_date} #{de32.alteration_time}"
end
# call_search_results = search.call_search_results
# puts search.hit_count
# puts call_search_results.length
