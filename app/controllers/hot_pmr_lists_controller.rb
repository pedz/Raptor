# -*- coding: utf-8 -*-

class HotPmrListsController < ApplicationController
  # Sets up a list of ldap entries which are the first line managers
  # of the area.  This will work for a normal person, a first line
  # manager, or a second line manager
  def index
    temp_user = application_user
    temp_ldap = temp_user.ldap
    if temp_ldap.ismanager != "Y"
      area_mgr = temp_ldap.mgr.mgr
    else
      if temp_ldap.manages.any? { |m| m.ismanager == "Y" }
        area_mgr = temp_ldap
      else
        area_mgr = temp_ldap.mgr
      end
    end
    @area_mgrs = area_mgr.manages
  end

  def show
    pmrs = []
    @dept_mgr = LdapUser.find(:first, params[:id]) # find manager
    @dept_mgr.manages.each do |person|             # for each person
      if user = User.find_by_ldap_id(person.mail) # if Raptor knows him
        user.retusers.each do |retuser|           # find thier retain id(s)
          next if (dr = Cached::Registration.find_by_signon(retuser.retid)).nil?
          logger.debug "DR found"
          # For each user, we look at PMRs are are:
          # 1) On their queue
          # 2) "Owned" by them
          # 3) "Resolved" by them
          
          # Part 1... find their queues, then the calls, then the pmr
          dr.queues.each do |queue|
            pmrs += queue.calls.map { |call| call.pmr }
          end

          # Part 2... find pmrs owned
          pmrs += dr.pmrs_as_owner

          # Part 3... find pmrs resolved
          pmrs += dr.pmrs_as_resolver
        end
      end
    end
    pmrs.uniq!
    pmrs = pmrs.find_all { |pmr| pmr.last_fetched && pmr.last_fetched > 2.weeks.ago }
    @hot_pmrs = pmrs.find_all do |pmr|
      # We are interested in three things.
      # 1) PMRs marked as hot
      # 2) PMRs marked as part of a crit sit
      # 3) PSAR marked with impact of 1
      #
      # For #1 and #2, we limit the PMRs to ones with updates within the
      # past two weeks. (This could be modified to be a "significant"
      # update where significant would be more than 2 non-empty lines...
      #
      # For #3, we limit the PSARs to within the past two weeks.
      # And we don't really want the PSARs but the PMRs that they
      # are attached to.
      pmr.hot || pmr.crit_sit || pmr.psars.any? do |psar|
        psar.psar_impact == 1 && psar.stop_time_date > 2.weeks.ago
      end
    end.sort { |a, b| a.pbc <=> b.pbc }
  end
end

