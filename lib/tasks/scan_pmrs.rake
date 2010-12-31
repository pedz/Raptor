
DAEMON_RETAIN_ID="305356"

desc "Scan PMRs looking for ones that have been purged"
task :scan_pmrs do
  Rake::Task["rake:environment"].invoke
  pmrs = Cached::Pmr.find(:all, :conditions => { :deleted => false })
  retuser = Retuser.find_by_retid(DAEMON_RETAIN_ID)
  params = Retain::ConnectionParameters.new(:signon   => retuser.retid,
                                            :password => retuser.password,
                                            :failed   => retuser.failed)
  begin
    pmrs.each do |cached_pmr|
      print "#{cached_pmr.pbc} "
      if pmr_valid?(params, cached_pmr)
        # cause the PMR to be fetched.
        # It might be that this causes an exception like the db unique
        # constraint problem or something like that.  We'll see how it
        # goes.
        j = cached_pmr.to_combined.comments
        puts "#{j}"
      else
        cached_pmr.deleted = true
        cached_pmr.save
        puts "gone"
      end
    end
    
  rescue Retain::FailedMarkedTrue, Retain::LogonFailed
    # Catch errors for bad password or login already in failed state
    # here.  We should probably send out an email.
    puts "Logon to retain failed"
    false

  rescue Exception => e
    # Some other problem happened so we give up.
    puts "Retain is not happy for some reason"
    puts e.message
    puts e.backtrace.join("\n")
    false
  end
end

#
# We try and fetch the pmr from retain.  If we can and if its creation
# date is the same, then we assume its the same PMR.
#
def pmr_valid?(params, cached_pmr)
  begin
    retain_pmr = Retain::Pmr.new(params,
                                 {
                                   :problem => cached_pmr.problem,
                                   :branch => cached_pmr.branch,
                                   :country => cached_pmr.country,
                                   :group_request => [[ :creation_date ]]
                                 })
    creation_date = retain_pmr.creation_date
    return creation_date == cached_pmr.creation_date
  rescue Retain::SdiReaderError => e
    if (e.sr == 115) && ((124..126) === e.ex)
      return false
    else
      raise e
    end
  end
end
