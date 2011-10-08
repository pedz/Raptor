# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

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

# god_retuser = Retuser.find_by_retid('073110')
god_retuser = Retuser.find_by_retid('305356')
retain_user_connection_parameters = Retain::ConnectionParameters.new(god_retuser)
Retain::Logon.instance.set(retain_user_connection_parameters)

all_ids.each do |ldap_id|
  num = 0
  begin
    user = User.find_by_ldap_id(ldap_id)
    num = -1
    next if user.nil?
    retuser = user.retusers.find(:first, :conditions => { :apptest => false })
    num = -2
    next if retuser.nil?
    dr = Combined::Registration.find_or_create_by_signon(retuser.retid)
    # I keep waffling on this.  Adding this will force us to get all
    # the PSARs but we shouldn't need to.  The flip side is, it really
    # doesn't cost that much.
    dr.refresh
    num = dr.psars.length
  rescue Exception => e
    num = -3
  ensure
    puts "#{ldap_id} has #{num} PSARS"
  end
end
