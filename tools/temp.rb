# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
ids = [ '000142',
'002262',
'003205',
'007123',
'011846',
'014541',
'017728',
'023153',
'023232',
'023232',
'024235',
# '030140',
# '031070',
# '031241',
# '032768',
# '066180',
# '074189',
# '075977',
# '077292',
# '078130',
# '081146',
# '082815',
# '083300',
# '083303',
# '086575',
# '088550',
# '094160',
# '095370',
# '096680',
# '097160',
# '097771',
# '099177',
# '137406',
# '194493',
# '194967',
# '214332',
# '220282',
# '229763',
# '307299',
# '313975',
# '319963',
# '389833',
# '389833',
# '395296',
# '395296',
# '598893',
# '628739',
# '664925',
# '675770',
# '749408',
# '756557',
# '786277',
# '910772',
# '914478',
# '917929',
# '918416',
# '951517',
# '952819',
# '960601',
# '960602',
# '960604',
# '960605',
# '960606',
# '960607',
# '960610',
# '960611',
# '960613',
# '960614',
# '960615',
# '960616',
# '960617',
# '960618',
'964016' ]

kwk='050954'
me='305356'
do_for=kwk
god_retuser = Retuser.find_by_retid('305356')
retain_user_connection_parameters = Retain::ConnectionParameters.new(god_retuser)
# retain_user_connection_parameters.registration_alt_signon = 1
Retain::Logon.instance.set(retain_user_connection_parameters)

ids.each do |do_for|
  begin
    dr = Combined::Registration.find_or_create_by_signon(do_for)
    dr.refresh
    r = ( 14.days.ago .. Time.now )
    status = "#{dr.psars.find_all { |psar| r.cover?(psar.psar_day) }.length} PSARs for the past 14 days."
  rescue Exception => e
    status = "caused an exception."
    puts e.message
    puts e.backtrace.join("\n")
  ensure
    puts "#{do_for} has #{status} PSARS"
  end
end
