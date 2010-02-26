# -*- coding: utf-8 -*-

module Combined
  class HotPmrTimeController < Retain::RetainController
    def index
      # BARF!!! cut and paste code from psars_controller (for now)
      
      local_params = params.symbolize_keys

      # Note that the "signon2" field in the SDI "PSRR" request is for
      # the PSAR Employee number -- not the normal Retain signon.  The
      # default is the current user
      retuser = local_params.delete(:retuser_id) || signon_user.signon
      
      # Only admins can search for others
      unless admin? || retuser == signon_user.signon
        render :status => 401, :layout => false, :file => "public/401.html"
        return
      end
      req_user = Combined::Registration.from_options :signon => retuser
      if @no_cache
        req_user.refresh
      end
      db_search_fields = Cached::Psar.fields_only(local_params)

      if local_params.has_key? :psar_start_date
        str = local_params[:psar_start_date]
        start_moc = Time.local(str[0...4].to_i, str[4...6].to_i, str[6...8].to_i).moc
      else
        start_moc = 0
      end
      
      if local_params.has_key? :psar_stop_date
        str = local_params[:psar_stop_date]
        stop_moc = Time.local(str[0...4].to_i, str[4...6].to_i, str[6...8].to_i).moc
      else
        stop_moc = 999999999
      end

      if local_params.has_key? :ot
        @ot = (local_params[:ot].to_f * 60).to_i
        logger.debug("OT #{@ot}")
      end

      # Just to make it look prettier
      psar_proxy = req_user.psars.stop_time_range(start_moc .. stop_moc)
      result = psar_proxy.find(:all,
                               :conditions => db_search_fields,
                               :include => :pmr)
      result = result.find_all { |psar| psar.hot? }
      result = result.group_by(&:saturday)
      @result = result.map do |saturday, days|
        # Group PSARs for this week by PMR
        pmr_list = days.group_by(&:pmr_id)

        # For each pmr in the list, run through the PSARs and total up
        # the time.
        pmr_list = pmr_list.map do |pmr_id, psar_list|
          time = psar_list.inject(0) { |memo, psar|
            memo += psar.chargeable_time_hex
            memo
          }
          # Result will be the pmr id and the total time for the week
          # for this PMR.
          [ pmr_id, time ]
        end
        # For each week, pmr list will be pmr id and total time tuples.
        [ saturday, pmr_list ]
      end

      logger.debug("result = #{@result}")
    end
  end
end