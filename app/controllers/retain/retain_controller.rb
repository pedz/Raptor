module Retain
  class RetainController < ApplicationController

    before_filter :validate_retuser

    private
    
    def validate_retuser
      logger.debug("DEBUG: in validate_retuser")
      u = session[:user]

      # Avoid extra db hits if session[:retain] already set
      if params = session[:retain]
        logger.debug("DEBUG: setting logon params #{__LINE__}")
        Logon.instance.set(params)
        return true
      end

      # If no retusers defined for this user, then redirect and
      # set up a retain user.
      if u.retusers.empty?
        session[:original_uri] = request.request_uri
        redirect_to new_retuser_url
        return false
      end

      # Pull together the signon/password and the host/port and create
      # a ConnectionParamters structure.  We hold this in the session
      # data.  We also set the Logon instance to use these settings.
      ru = u.retusers[0]
      c = Retain::Config.symbolize_keys[RetainConfig::Node][0].symbolize_keys
      params = ConnectionParameters.new(:host => c[:host],
                                        :port => c[:port],
                                        :signon => ru.retid,
                                        :password => ru.password)
      session[:retain] = params
      logger.debug("DEBUG: setting logon params #{__LINE__}")
      Logon.instance.set(params)
      return true
    end

    #
    # I'm going to put a local copy of this here.  As the html view
    # changes, the fields needed should be added here.  I do not put
    # in the :alterable_format_text_lines here.  We request those only
    # sometimes and that field is appended if we want to receive them.
    #
    LOCAL_GROUP_REQUEST = [
                                :queue_name,
                                :center,
                                :h_or_s,
                                :ppg,
                                :priority,
                                :severity,
                                :p_s_b,
                                :comments,
                                :customer_name,
                                :cstatus,
                                :nls_scratch_pad_1,
                                :nls_scratch_pad_2,
                                :nls_scratch_pad_3,
                                :nls_text_lines,
                                :pmr_owner_name,
                                :pmr_owner_employee_number,
                                :resolver_id,
                                :resolver_name,
                                :problem_e_mail,
                                :next_queue,
                                :next_center
                               ].freeze
    

    # Takes a hash which defines a call.  Returns a tuple array whcih
    # is the Retain::Call, Retain::Pmr, Cached::Pmr, text_lines
    def call_to_all(options)

      # Get the call from retain.  I'm afraid to cache these
      call = Retain::Call.new(options)
      logger.info("#{call.problem},#{call.branch},#{call.country}")

      # This is hash is reused so make a local variable.
      pmr_hash = {
        :problem => call.problem,
        :branch => call.branch,
        :country => call.country
      }

      # Get the cached pmr if one exists.
      cached_pmr = Cached::Pmr.find(:first, :conditions => pmr_hash)

      # When we fetch the text lines from Retain, it pads with blank
      # lines up to the page boundary.
      
      if cached_pmr
        last_cached_line_number = cached_pmr.cached_text_lines.length
        last_cached_page = (last_cached_line_number / 16) + 1
      else
        page_offset = 0
        last_cached_page = 0
        last_cached_line_number = 0
        # Create a fresh PMR if we did not have one cached
        cached_pmr = Cached::Pmr.new(pmr_hash)
      end
      logger.info("DEBUG: last_cached_page=#{last_cached_page}, " +
                   "last_cached_line_number=#{last_cached_line_number}")

      if last_cached_page > 0
        pmr_hash[:beginning_page_number] = last_cached_page
      end
      pmr = Retain::Pmr.new(pmr_hash)
      local_group_request = LOCAL_GROUP_REQUEST.dup

      # If the PMR is not in the cache, we request the FA lines;
      # otherwise we do not.
      if last_cached_page == 0
        local_group_request << :alterable_format_text_lines
      end
      pmr.group_request = local_group_request

      # Fetch the record from Retain here.
      text_lines = pmr.nls_text_lines
      #
      # The way that the reply gunk works is a single text line will
      # have a value of just a single text line but a bunck of them
      # will be an array of text lines.  So, we test to see if
      # text_lines is a single element of type text line.  If it is,
      # we then check to see if it is blank; converting text_lines to
      # an empty element for a blank line and an array with a single
      # element in the other case.  We do the same thing later for
      # alt_lines.
      #
      if text_lines.is_a?(Retain::TextLine)
        logger.info("DEBUG: text_lines.class=#{text_lines.class}")
        if text_lines.text.blank?
          text_lines = []
        else
          text_lines = [ text_lines ]
        end
      else
        logger.info("DEBUG: text_lines.length=#{text_lines.length}")
      end

      # Some requests will not have the alterable format text so make
      # this conditional.  Becaues it is conditional, this can not be
      # the first thing we look at because it has not been fetched
      # yet.
      if pmr.alterable_format_text_lines?
        logger.info("DEBUG: Received alt lines")
        alt_lines = pmr.alterable_format_text_lines
        if alt_lines.is_a?(Retain::TextLine)
          logger.info("DEBUG: alt_lines.class=#{alt_lines.class}")
          if alt_lines.text.blank?
            alt_lines = []
          else
            alt_lines = [ alt_lines ]
          end
        else
          logger.info("DEBUG: alt_lines.length=#{alt_lines.length}")
        end
        #
        # The way an FA is displayed is that it consumes a multiple of
        # pages.  Here, we pad with blank lines to a page boundry.
        #
        mod = alt_lines.length % 16
        if mod != 0
          alt_lines += Retain::TextLine.blank_lines(16 - mod)
        end
      else
        alt_lines = []
      end

      # Retain puts the FA lines at the top.
      new_text_lines = alt_lines + text_lines

      if pmr.beginning_page_number?
        # The minus 2 is because the first page of text on the screen
        # Retain calls Page 2.  We need a zero based index so the
        # multiplies come out right.  This should not be page_offset.
        beginning_page_number = pmr.beginning_page_number - 2
        logger.info("DEBUG: pmr.beginning_page_number = " +
                     "#{pmr.beginning_page_number}")
        beginning_page_number = 0 if beginning_page_number < 0
      else
        beginning_page_number = 0
      end
      beginning_line_number = beginning_page_number * 16
      logger.info("DEBUG: beginning_page_number = #{beginning_page_number}")
      logger.info("DEBUG: first line: #{new_text_lines[0].text}")

      # For each line, we check to see if we already have it in the
      # cache.  If we do and it has not changed, we do nothing.  If it
      # is cached and it changes (from a blank line to a text line),
      # we modify the existing record.  If it is not cached, we create
      # a new line.
      cached_text_lines = cached_pmr.cached_text_lines
      new_text_lines.each_with_index do |line, index|
        line_number = beginning_line_number + index
        if last_cached_line_number > line_number
          cached_line = cached_text_lines[line_number]
          unless (cached_line.text == line.text &&
                  cached_line.line_type == line.line_type)
            logger.info("DEBUG: before: #{cached_line.line_number} " +
                         "#{cached_line.line_type} '#{cached_line.text}'")
            logger.info("DEBUG:  after: #{line_number} #{line.line_type} '" +
                         "#{line.text}'")
            cached_line.line_type = line.line_type
            cached_line.text = line.text
            cached_line.save!
          end
        else
          cached_text_line =
            Cached::TextLine.new(:line_number => line_number,
                                 :line_type   => line.line_type,
                                 :text        => line.text,
                                 :code_page   => line.code_page)
          cached_text_lines << cached_text_line
        end
      end
      cached_pmr.save!
      text_lines = cached_pmr.cached_text_lines
      return [ call, pmr, cached_pmr, text_lines ]
    end
  end
end
