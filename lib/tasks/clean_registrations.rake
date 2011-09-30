# -*- coding: utf-8 -*-

desc "Remove registrations that are no longer valid"
task :clean_registrations do
  Rake::Task["rake:environment"].invoke
  top = Rails.root
  user = User.find_by_ldap_id("pedzan@us.ibm.com")
  retuser = user.current_retain_id
  params = Retain::ConnectionParameters.new(retuser)
  regs = Cached::Registration.find(:all)
  puts regs.length
  Cached::Registration.all.each do |reg|
    v = Retain::Registration.valid?(params, :signon => retuser.retid, :secondary_login => reg.signon)
    unless v
      puts "Deleting #{reg.signon}"
      reg.delete
    end
  end
end
