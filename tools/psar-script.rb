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
  status = "Unset"
  begin
    user = User.find_by_ldap_id(ldap_id)
    if user.nil?
      status = "no User entry."
      next
    end
    retuser = user.retusers.find(:first, :conditions => { :apptest => false })
    if retuser.nil?
      status = "no Retuser entry."
      next
    end
    dr = Combined::Registration.find_or_create_by_signon(retuser.retid)
    # I keep waffling on this.  Adding this will force us to get all
    # the PSARs but we shouldn't need to.  The flip side is, it really
    # doesn't cost that much.
    dr.refresh
    r = ( 14.days.ago .. Time.now )
    status = "#{dr.psars.find_all { |psar| r.cover?(psar.psar_day) }.length} PSARs for the past 14 days."
  rescue Exception => e
    status = "caused an exception."
  ensure
    puts "#{ldap_id} has #{status} PSARS"
  end
end
