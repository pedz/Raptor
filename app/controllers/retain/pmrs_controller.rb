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
      
      # This is a hack.  I had my belongs_to association botched and
      # the primary_call was not being created.  This checks to see if
      # the primary call is nil.  If it is, it forces the code to go
      # back to retain and, hopefully, set up the primary call.  I
      # assume, eventually, this could be removed.  Likewise,
      # eventually, the primary fields could be marked as 'not null'.
      if @pmr.primary_call.nil?
        @pmr.last_alter_timestamp = nil
        @pmr.mark_cache_invalid
      end
      
      # Pick the first non-empty primary or secondary
     call = [ @pmr.primary_call, @pmr.secondaries ].flatten.select { |e| e }.first

      respond_to do |format|
        format.html {
          # Redirect to a call if there is one
          unless call.nil?
            redirect_to(call)
          end
        }
        format.xml { render :xml => @pmr.to_xml( :include => :text_lines ) }
      end
    end

    private
    
    # POST
    def opc
      pmr = Combined::Pmr.from_param!(params[:id], signon_user)
      opc_div = "opc_div_#{pmr.to_id}"
      reply_span = "opc_reply_span_#{pmr.to_id}"
      pmr_opc = Retain::PmrOpc.new(pmr)
      opc_options = params[:retain_opc].merge(:user_name => application_user.ldap_id,
                                              :retain_params => retain_user_connection_parameters)
      text, do_fade = pmr_opc.update(opc_options)
      render_message(reply_span, text) do |page|
        if do_fade
          page.visual_effect(:fade, reply_span, :duration => 5.0)
          page[opc_div].redraw
          page[opc_div].close
        end
      end
    end
    
    # GET /retain_pmrs/new
    # GET /retain_pmrs/new.xml
    def new
      @retain_pmr = RetainPmr.new
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @retain_pmr }
      end
    end
    
    # GET /retain_pmrs/1/edit
    def edit
      @retain_pmr = RetainPmr.find(params[:id])
    end
    
    # POST /retain_pmrs
    # POST /retain_pmrs.xml
    def create
      @retain_pmr = RetainPmr.new(params[:retain_pmr])
      
      respond_to do |format|
        if @retain_pmr.save
          flash[:notice] = 'RetainPmr was successfully created.'
          format.html { redirect_to(@retain_pmr) }
          format.xml  { render :xml => @retain_pmr, :status => :created, :location => @retain_pmr }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @retain_pmr.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /retain_pmrs/1
    # PUT /retain_pmrs/1.xml
    def update
      @retain_pmr = RetainPmr.find(params[:id])
      
      respond_to do |format|
        if @retain_pmr.update_attributes(params[:retain_pmr])
          flash[:notice] = 'RetainPmr was successfully updated.'
          format.html { redirect_to(@retain_pmr) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @retain_pmr.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /retain_pmrs/1
    # DELETE /retain_pmrs/1.xml
    def destroy
      @retain_pmr = RetainPmr.find(params[:id])
      @retain_pmr.destroy
      
      respond_to do |format|
        format.html { redirect_to(retain_pmrs_url) }
        format.xml  { head :ok }
      end
    end
    
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

    # The equivalent of update in the calls controller.  We do not
    # really create a PMR but install use this entry point to do
    def update
      @pmr = Combined::Pmr.from_param!(params[:id], signon_user)
      render :json => "#{@pmr.problem}"
    end

    private

    def create_reply_span(msg, error_class)
      ApplicationController.helpers.content_tag(:span, msg + ". ", :class => error_class)
    end

    def create_reply_spans(msgs)
      msgs.map do |h|
        create_reply_span(h[:msg], h[:css_class])
      end.join('')
    end

    def render_message(area, msgs)
      if (request.xhr?)
        text = create_reply_spans(msgs)
        render(:update) do |page|
          page.replace_html area, text
          page.show area
          if block_given?
            yield page
          end
        end
      else
        render :json => msgs
      end
    end
  end
end
