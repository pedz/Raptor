# -*- coding: utf-8 -*-

desc "Refresh registrations"
task :refresh_registrations do
  Rake::Task["rake:environment"].invoke
  top = Rails.root
  user = User.find_by_ldap_id("pedzan@us.ibm.com")
  retuser = user.current_retain_id
  retain_user_connection_parameters = Retain::ConnectionParameters.new(retuser)
  Retain::Logon.instance.set(retain_user_connection_parameters)
  regs = Combined::Registration.find(:all)
  puts regs.length
  regs.each do |reg|
    puts reg.psar_number
  end
end
