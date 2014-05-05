# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class RegistrationController < RetainController
    def show
      @reg = Combined::Registration.find_or_initialize_by_signon(params[:id])
    end

    def owner_list
      user = Combined::Registration.find(:first,
                                         :conditions => {
                                           :signon => params[:id],
                                           :apptest => retain_user_connection_parameters.apptest
                                         })
      favorite_queues = application_user.favorite_queues
      favorite_signons = []
      favorite_queues.each do |favorite_queue|
        if ((queue = favorite_queue.queue) && (infos = queue.queue_infos))
          infos.each { |info| favorite_signons << info.owner.signon }
        end
      end
      favorite_signons.uniq!
      favorite_signons.sort!

      # Temp lists to append to
      favorites = []
      same_center = []
      # start off ordered by name so each subsection will be ordered as well
      all = Combined::Registration.find(:all,
                                        :conditions => {
                                          :apptest => retain_user_connection_parameters.apptest
                                        },
                                        :order => "name")
      all.each do |reg|
        case
        when reg.signon == user.signon
          ;
        when favorite_signons.include?(reg.signon)
          favorites << reg
        when ((reg.software_center_id == user.software_center_id) ||
              (reg.hardware_center_id == user.hardware_center_id))
          same_center << reg
        end
      end
      logger.debug("favorites.length = #{favorites.length} same_center.length = #{same_center.length}")
      list = [ user ] + favorites + same_center
      render :json => list.map { |r| [ r.signon, r.name ] }.to_json
    end
  end
end
