
me = LdapUser.find(:first, :attribute => 'mail', :value => 'pedzan@us.ibm.com')

my_manager = me.mgr

my_2nd_line = my_manager.mgr

all_ids = []

all_ids.push(my_2nd_line.mail)
my_2nd_line.manages.each do |m|
  if m.mail.is_a? Array
    m.mail.each { |m| all_ids.push(m) }
  else
    all_ids.push(m.mail)
  end

  m.manages.each do |p|
    if p.mail.is_a? Array
      p.mail.each { |m| all_ids.push(m) }
    else
      all_ids.push(p.mail)
    end
  end
end

god_retuser = Retuser.find_by_retid('073110')
retain_user_connection_parameters = Retain::ConnectionParameters.new(god_retuser)
Retain::Logon.instance.set(retain_user_connection_parameters)

all_ids.each do |ldap_id|
  puts "Processing #{ldap_id}"
  user = User.find_by_ldap_id(ldap_id)
  next if user.nil?
  retuser = user.retusers.find(:first, :conditions => { :apptest => false })
  next if retuser.nil?
  dr = Combined::Registration.find_by_signon(retuser.retid)
  dr.psars
end
