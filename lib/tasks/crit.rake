# -*- coding: utf-8 -*-

EMPTY_CRIT_SIT = Regexp.new(" {14}|-{14}|_{14}")
COMMA_DOT = Regexp.new("[,.]")
LINE_SPLIT = Regexp.new("(/ Alert)?:")

desc "Process crit-sit-pmrs.txt file"
task :add_crits do
  Rake::Task["rake:environment"].invoke
  top = Rails.root
  user = User.find_by_ldap_id("pedzan@us.ibm.com")
  retuser = user.current_retain_id
  params = Retain::ConnectionParameters.new(retuser)
  File.open(top + "public/crit-sit-pmrs.txt") do |f|
    f.each_line do |l|
      crit, pmrs = l.split(LINE_SPLIT)
      pmrs.split(" ").each do |pmr|
        problem, branch, country = pmr.split(COMMA_DOT)
        pmr_options = {
          :problem => problem,
          :branch => branch,
          :country => country
        }
        pmpb_options = { :group_request => [[ :problem_crit_sit ]] }.merge(pmr_options)
        retain_pmr = Retain::Pmr.new(params, pmpb_options)
        begin
          problem_crit_sit = retain_pmr.problem_crit_sit    # cause the fetch
        rescue ::Retain::LogonFailed => e
          puts "#{e.message} #{e.logon_return} #{e.logon_reason}"
          retuser.failed = true
          retuser.logon_return = e.logon_return
          retuser.logon_reason = e.logon_reason
          retuser.save
          exit 1

        rescue ::Retain::FailedMarkedTrue => e
          puts "#{e.message}"
          exit 1

        rescue Exception => e
          # puts "Exception hit -- bailing #{e.class} #{e.message}"
          # puts "#{problem},#{branch},#{country} not fetched"
          # exit 1
          next
        end
        
        next unless EMPTY_CRIT_SIT.match(problem_crit_sit)
        
        pmpu_options = { :problem_crit_sit => crit }.merge(pmr_options)
        pmpu = Retain::Pmpu.new(params, pmpu_options)
        begin
          pmpu.sendit(Retain::Fields.new)
        rescue Exception
          puts "#{problem},#{branch},#{country} alter caught an exception"
        end
        rc = pmpu.rc
        if rc == 0
          puts "#{problem},#{branch},#{country} set to #{crit}"
        else
          puts "#{problem},#{branch},#{country} altered failed"
        end
      end
    end
  end
end
