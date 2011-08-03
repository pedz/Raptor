# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# N O T E: this controller is not in the retain or combined
# subdirectories.  The queries should not assume that data can be
# fetched from Retain.  Rather I just want this to be a database only
# controller.  As such, we must check to see if the fields are set
# before we use them because all the automagic stuff is not active.

class HotPmrListsController < ApplicationController
  # Sets up a list of ldap entries which are the first line managers
  # of the area.  This will work for a normal person, a first line
  # manager, or a second line manager
  def index
    temp_user = application_user
    temp_ldap = temp_user.ldap_user
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
    all_pmrs = []
    # pmr_lists is a list of pmrs per person
    @pmr_lists = { }
    @dept_mgr = LdapUser.find(:first, params[:id]) # find manager
    @manages = @dept_mgr.manages
    @manages.each do |person|                     # for each person
      if user = User.find_by_ldap_id(person.mail) # if Raptor knows him
        user.retusers.each do |retuser|           # find their retain id(s)
          pmrs = []
          next if (dr = Cached::Registration.find_by_signon_and_apptest(retuser.retid, retuser.apptest)).nil?
          # logger.debug "DR found"
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

          pmrs.uniq!
          @pmr_lists[dr.name] = pmrs.map { |pmr| pmr.pbc }
          all_pmrs += pmrs
        end
      end
    end

    # Remove duplicates
    all_pmrs.uniq!

    # Weed out the ones we are not interested in.
    all_pmrs = all_pmrs.find_all do |pmr|
      (pmr.alter_time > 2.weeks.ago) &&
        (pmr.problem_status_code.nil? ||
         (pmr.problem_status_code[0,2] == "OP"))
    end
    
    @hot_pmrs = all_pmrs.find_all do |pmr|
      # We are interested in three things.
      # 1) PMRs marked as hot
      # 2) PMRs marked as part of a crit sit
      # 3) PSAR marked with impact of 1
      #
      # For #1 and #2, we limit the PMRs to ones altered within the
      # past two weeks (with the code above).  This could be changed
      # to be a significant update or an update by someone in the
      # group.
      #
      # For #3, we limit the PSARs to within the past two weeks.
      # And we don't really want the PSARs but the PMRs that they
      # are attached to.
      pmr.hot || pmr.crit_sit || pmr.psars.any? do |psar|
        psar.psar_impact == 1 && psar.stop_time_date > 2.weeks.ago
      end
    end.sort { |a, b| a.pbc <=> b.pbc }
    @hot_pmrs_pbc = @hot_pmrs.map { |pmr| pmr.pbc }
  end
end

