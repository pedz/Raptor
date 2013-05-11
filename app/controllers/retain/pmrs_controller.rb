# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class PmrsController < RetainController
    # GET /retain_pmrs/1
    # GET /retain_pmrs/1.xml
    def show
      # logger.debug("params 1 = #{retain_user_connection_parameters.inspect}")
      @pmr = Combined::Pmr.from_param!(params[:id], signon_user)
      
      # The is not a hack... The primary call can become null for
      # various reasons.  In particular, if the call is deleted,
      # "primary" is set to null.
      if @pmr.primary_call.nil?
        @pmr.last_alter_timestamp = nil
        @pmr.mark_cache_invalid
        force_update = @pmr.ppg
      end
      
      respond_to do |format|
        format.html {
          # if primary call, use it -- otherwise, use the pmr show page (default)
          unless @pmr.primary.nil?
            redirect_to(@pmr.primary_call)
          end
        }
        format.xml { render :xml => @pmr.to_xml( :include => :text_lines ) }
      end
    end
    
    # POST
    def opc
      suffix = "\x0B"
      number = "395350"
      pmr = Combined::Pmr.from_param!(params[:id], signon_user)
      # logger.debug("service_request = #{pmr.service_request}")
      # logger.debug("set = #{params[:set]}")
      # logger.debug("comp = #{params[:comp]}")
      # logger.debug("kv.length = #{params[:kv].length}")
      # params[:kv].each_with_index do |h, index|
      #   logger.debug("kv[#{index}] = { key => #{h['key']}, value = #{h['value']}}")
      # end
      s = pmr.service_request + params[:set] + params[:comp] + suffix
      s += params[:kv].map do |h|
        key = h['key']
        value = h['value']
        value = application_user.ldap_id if value == '__user'
        key + value + suffix
      end.join('')
      s = "%-1122s" % s
      s += number + "                        "
      options = pmr.to_options
      options[:opc] = s
      pmpu = Retain::Pmpu.new(retain_user_connection_parameters, options)
      fields = Retain::Fields.new
      pmpu.sendit(fields)
      rc = pmpu.rc
      logger.debug("rc = #{rc}")
      render json: s
    end

    # POST
    def addtime
      options = Combined::Pmr.param_to_options(params[:id])
      options.merge!(params[:psar].symbolize_keys)
      hours = options.delete(:hours).to_i
      minutes = options.delete(:minutes).to_i
      options[:psar_actual_time] = (hours * 10) + (minutes / 6).to_i
      options[:psar_chargeable_time] = hours * 256 + minutes
      # logger.debug("options: #{options.inspect}")
      psar = Retain::Psrc.new(retain_user_connection_parameters, options)
      begin
        psar.sendit(Retain::Fields.new)
      rescue
        true
      end
      if psar.rc == 0
        err_text = "Add Time Succeeded"
        err_code = 0
        err_class = "sdi-normal"
      else
        err_text = psar.error_message
        err_code = err_text[-3 ... err_text.length].to_i
        
        if (600 .. 700) === err_code
          err_class = "sdi-warning"
        else
          err_class = "sdi-error"
        end
      end
      full_text = "<span class='#{err_class}'>#{err_text}</span>"

      render(:update) { |page| page.replace_html 'add-time-reply', full_text}
    end

    # POST
    def addtxt
      options = Combined::Pmr.param_to_options(params[:id])
      # logger.debug("options=#{options.inspect}")
      lines = params[:newtext].split("\n")
      # logger.debug("lines before=#{lines.inspect}")
      lines = lines.map { |line|
        l = []
        while line.length > 72
          this_end = 72
          while this_end > 0 && line[this_end] != 0x20
            this_end -= 1
          end
          if this_end == 0      # no spaces found
            l << line[0 ... 72]
            line = line[72 ... line.length]
            next
          end
          
          new_start = this_end + 1
          while new_start < line.length && line[new_start] == 0x20
            new_start += 1
          end
          l << line[0 ... this_end]
          line = line[new_start ... line.length]
        end
        l << line
        l
      }.flatten
      # logger.debug("lines after=#{lines.inspect}")
      options[:addtxt_lines] = lines
      addtxt = Retain::Pmat.new(retain_user_connection_parameters, options)
      begin
        addtxt.sendit(Retain::Fields.new)
      rescue Retain::SdiReaderError => e
        true
      end
      render(:update) { |page| page.replace_html 'addtxt-reply', "Addtxt rc = #{addtxt.rc}"}
    end

    private

  end
end
