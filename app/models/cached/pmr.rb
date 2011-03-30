# -*- coding: utf-8 -*-

module Cached
  # = Retain PMR Model
  #
  # The model that represents the Problem Record from Retain.  The
  # table this model is stored in is <em>cached_pmrs</em>.
  #
  # ==Fields
  #
  # <em>id - integer</em>::
  #   The key field for the table.
  # <em>problem - character varying(5)</em>::
  #   A PMR is designated by a 3-tuple: problem, branch, and country.
  # <em>branch - character varying(3)</em>::
  #   Retain branch the PMR was opened from.
  # <em>country - character varying(3)</em>::
  #   Retain country the PMR was opened from.
  # <em>customer_id - integer</em>::
  #   Foreign key into the <em>cached_customers</em> table.  The end
  #   customer who opened the PMR.
  # <em>owner_id - integer</em>::
  #   Foreign key into the <em>cached_registrations</em> table.
  #   According to the process, this is the owner of the PMR: the
  #   person currenty most responsible to get it solved.
  # <em>resolver_id - integer</em>::
  #   Foreign key into the <em>cached_registrations</em> table.  This
  #   is the person most active in resolving the issue.
  # <em>center_id - integer</em>::
  #   Foreign key into the <em>cached_centers</em> table.  In Retain,
  #   a PMR holds the 4-tuple queue_name, center, h_or_s, and ppg to
  #   its primary call.  center_id points to the record in
  #   <em>cached_centers</em> for that center.
  # <em>queue_id - integer</em>::
  #   Foreign key into the <em>cached_queues</em> table.  See
  #   <em>center_id</em> above.  In brief, this specifies the queue
  #   that the primary call is on.
  # <em>primary - integer</em>::
  #   Foreign key into the <em>cached_calls</em> table.  See
  #   <em>center_id</em> above.  The <em>primary_call</em>
  #   attribute uses <em>primary</em> to store the foreign key.
  # <em>next_center_id - integer</em>::
  #   Foreign key into the <em>cached_centers</em> table.  As part of
  #   the process, the next center and next queue should be set to
  #   point to a particular queue and center.  Retain holds these
  #   fields as next_center and next_queue.  When a PMR is fetched and
  #   stored, these fields are converted to a reference to the
  #   <em>cached_centers</em> and <em>cached_queues</em> tables if
  #   possible.  If not, no error is raised.  Retain is not always
  #   consistent and this forgiveness of the database constraints
  #   allows it to work when Retain is not consistent.
  # <em>next_queue_id - integer</em>::
  #   Foreign key into the <em>cached_queues</em> table.  See
  #   <em>next_center_id</em> above.
  # <em>severity - integer</em>::
  #   The severity of the PMR
  # <em>component_id - character varying(12)</em>::
  #   Foreign key to the <em>cached_components</em> table.  The
  #   component currently assigned to the PMR.
  # <em>problem_e_mail - character varying(64)</em>::
  #   Customer's email... note that this is a PMR attribute and not a
  #   call attribute.
  # <em>creation_date - character varying(9)</em>::
  #   Creation date of the PMR from Retain.
  # <em>creation_time - character varying(5)</em>::
  #   Creation time of the PMR from Retain.
  # <em>alteration_date - character varying(9)</em>::
  #   Last alteration date of the PMR from Retain.
  # <em>alteration_time - character varying(5)</em>::
  #   Last alteration time of the PMR from Retain.
  # <em>sec_1_queue - character varying(6)</em>::
  # <em>sec_1_center - character varying(3)</em>::
  # <em>sec_1_h_or_s - character varying(1)</em>::
  # <em>sec_1_ppg - character varying(3)</em>::
  # <em>sec_2_queue - character varying(6)</em>::
  # <em>sec_2_center - character varying(3)</em>::
  # <em>sec_2_h_or_s - character varying(1)</em>::
  # <em>sec_2_ppg - character varying(3)</em>::
  # <em>sec_3_queue - character varying(6)</em>::
  # <em>sec_3_center - character varying(3)</em>::
  # <em>sec_3_h_or_s - character varying(1)</em>::
  # <em>sec_3_ppg - character varying(3)</em>::
  #   These fields are not currently used but the PMR holds the data,
  #   just like for the primary, of the three possible secondaries
  #   that a PMR can have.  From these fields, the list of calls could
  #   be found.  These fields are essentially raw Retain fields at
  #   this point.
  # <em>created_at - timestamp without time zone</em>::
  #   Usual timestamp of when the database record was first created.
  # <em>updated_at - timestamp without time zone</em>::
  #   Timestamp to record the last time the database record was
  #   updated.  This timestamp is used to determine when Retain should
  #   be queried Retain under normal conditions to verify that the
  #   current local copy is up to date.  See also the last_fetched
  #   timestamp.
  # <em>last_alter_timestamp - bytea</em>::
  #   This is the raw unaltered field from Retain that can be used in
  #   subsequent calls to get only what has changed in the PMR from
  #   Retain.
  # <em>dirty - boolean</em>::
  #   This bit is set when we know that the database entry is out of
  #   date.
  # <em>special_application - character varying(1)</em>::
  #   An "E" in this field indicates the PMR is electronic.  This is
  #   used, in particular, with Hitachi PMRs to enable the check box
  #   to do the "CR CA" rather than the normal requeue.
  # <em>last_fetched - timestamp without time zone</em>::
  #   This is the time stamp of when the call was fetched from Retain
  #   *and* it was different than what was in the database.  It is the
  #   time stamp used to determine if a page, action, or fragment
  #   cache entry is up to date.
  class Pmr < Base
    set_table_name "cached_pmrs"
    has_many   :calls,        :class_name => "Cached::Call"
    belongs_to :owner,        :class_name => "Cached::Registration"
    belongs_to :resolver,     :class_name => "Cached::Registration"
    belongs_to :customer,     :class_name => "Cached::Customer"
    belongs_to :center,       :class_name => "Cached::Center"
    belongs_to :queue,        :class_name => "Cached::Queue"
    belongs_to :primary_call, :class_name => "Cached::Call", :foreign_key => "primary"
    belongs_to :next_center,  :class_name => "Cached::Center"
    belongs_to :next_queue,   :class_name => "Cached::Queue"
    has_many   :psars,        :class_name => "Cached::Psar"
    has_many(:scratch_pad_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::SCRATCH_PAD}",
             :class_name => "Cached::TextLine",
             :order => "line_number ASC",
             :foreign_key => "pmr_id")
    has_many(:alterable_format_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::ALTERABLE_FORMAT}",
             :class_name => "Cached::TextLine",
             :order => "line_number ASC",
             :foreign_key => "pmr_id")
    has_many(:text_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::TEXT_LINE}",
             :class_name => "Cached::TextLine",
             :order => "line_number ASC",
             :foreign_key => "pmr_id",
	     :dependent => :destroy)
    has_many(:information_text_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::INFORMATION_TEXT}",
             :class_name => "Cached::TextLine",
             :order => "line_number ASC",
             :foreign_key => "pmr_id")

    set_as_json_default_options(:methods => [ :last_ct_time ])

    def all_text_lines
      # Note for future: when a method in the cached model directly
      # references an database association or field, the checks to
      # make sure the database is up to date and valid are bypassed.
      # Usually this is not what you want.
      #
      # The flip side is when a method in the cached model is called,
      # it must return back a cached model -- not a combined model.
      # This is because the combined missing_method will wrap it and a
      # combined model can not be wrapped again.
      #
      # So, for now, I fetch a simple non-constant field to make sure
      # the cached_pmr and its lines are up to date.
      #
      # when adding the hot_pmr_list page, I wanted to be able to work
      # with just cached objects, so the line below was removed.
      #
      # to_combined.severity
      
      # Then I return the lines
      text_lines
    end
    once :all_text_lines
    
    # This marks the problem as dirty as well as all calls in the
    # database and the queues they are on.  This only marks entities
    # in the database.
    def mark_all_as_dirty
      self.mark_as_dirty
      self.calls.each do |call|
        call.mark_as_dirty
        call.queue.mark_as_dirty
      end
    end

    def etag
      # old method
      # ret = "#{self.problem},#{self.branch},#{self.country}"
      # last_alter_timestamp.each_byte { |b| ret << ("%02x" % b) }
      # ret

      # New method: an array that is the id and the last alter timestamp
      [ problem, branch, country, last_alter_timestamp ]
    end
    once :etag

    def system_inserted_lines
      all_text_lines.find_all { |text_line| text_line.text_type == :system_inserted }
    end
    once :system_inserted_lines
    
    def service_given_lines
      system_inserted_lines.find_all { |text_line| text_line.service_given }
    end
    once :service_given_lines
    
    def signature_lines
      all_text_lines.find_all { |text_line|
        text_line.text_type == :signature
      }.map { |text_line|
        Retain::SignatureLine.new(text_line.text)
      }
    end
    once :signature_lines
    
    def signature_line_stypes(stype)
      signature_lines.find_all { |sig| sig.stype == stype }
    end
    
    # This may grow over time.  Currently it parses the
    # alteration_date and alteeration_time from the PMR to provide a
    # timestamp of the last alteration time.
    def alter_time
      return create_time if alteration_date.nil? || alteration_time.nil?
      # should never be true but just in case.
      ad = self.alteration_date
      at = self.alteration_time
      # Note, the creation date and time from the PMR is in the time
      # zone of the specialist who created the PMR.  I don't know
      # how to find out who that specialist was and, even if I
      # could, I don't know his time zone.  So, I fudge and put the
      # create time according to the time zone of the customer.  So
      # this is going to be wrong sometimes.  But, it should never
      # be used anyway.
      if customer && customer.tz
        tz = customer.tz
      else
        tz = 0
      end
      DateTime.civil(2000 + ad[1..2].to_i, # not Y2K but who cares?
                     ad[4..5].to_i,        # month
                     ad[7..8].to_i,        # day
                     at[0..1].to_i,        # hour
                     at[3..4].to_i,        # minute
                     0,                    # second
                     tz)                   # time zone
    end

    # The creation_date and creation_time appear to be from the
    # perspective of the person who opened the PMR.  To get that back
    # to UTC would be really hard.  So, we find the first CE entry and
    # use its date.
    def create_time
      if (sig = signature_line_stypes('CE')).empty?
        if customer && customer.tz
          tz = customer.tz
        else
          tz = 0
        end

        # should never be true but just in case.
        cd = self.creation_date
        ct = self.creation_time
        if cd.nil? || ct.nil?
          return created_at
        end
        # Note, the creation date and time from the PMR is in the time
        # zone of the specialist who created the PMR.  I don't know
        # how to find out who that specialist was and, even if I
        # could, I don't know his time zone.  So, I fudge and put the
        # create time according to the time zone of the customer.  So
        # this is going to be wrong sometimes.  But, it should never
        # be used anyway.
        DateTime.civil(2000 + cd[1..2].to_i, # not Y2K but who cares?
                       cd[4..5].to_i,        # month
                       cd[7..8].to_i,        # day
                       ct[0..1].to_i,        # hour
                       ct[3..4].to_i,        # minute
                       0,                    # second
                       tz)                   # time zone
      else
        sig.first.date
      end
    end
    once :create_time
    
    def last_ct
      signature_line_stypes('CT').last
    end
    once :last_ct

    def last_ct_time
      if (last = last_ct)
        last.date
      else
        create_time
      end
    end
    once :last_ct_time

    # age of the PMR in days
    def age
      # Note that DateTime does this subtraction correctly even if
      # they are different time zones.
      DateTime.now - create_time
    end
    once :age

    ENVIRONMENT  = "environment|env".freeze
    CUSTOMER     = "customer rep".freeze
    PROBLEM      = "problem".freeze
    ACTION_TAKEN = "action taken".freeze
    ACTION_PLAN  = "action plan".freeze
    TESTCASE     = "testcase".freeze
    ECPAAT_HEADINGS = [ "Environment",
                        "Customer Rep",
                        "Problem",
                        "Action Taken",
                        "Action Plan",
                        "Testcase" ].freeze
    ECPAAT_REGEXP = Regexp.new("^(" +
                               "(#{ENVIRONMENT})|" +
                               "(#{CUSTOMER})|" +
                               "(#{PROBLEM})|" +
                               "(#{ACTION_TAKEN})|" +
                               "(#{ACTION_PLAN})|" +
                               "(#{TESTCASE})" +
                               "): *(.*)$", Regexp::IGNORECASE).freeze

    #
    # The Anderson tools puts a '.' on a line to create an empty line.
    # The regexp below is true if the whole line is blank or if the
    # initial character is a period followed by blanks.
    BLANK_REGEXP = Regexp.new("^[. ] *$").freeze
    
    def ecpaat_lines
      temp_hash = ecpaat
      temp_lines = []
      ECPAAT_HEADINGS.each { |heading|
        unless (lines = temp_hash[heading]).nil?
          temp_lines << heading + ": " + lines.shift
          temp_lines += temp_hash[heading]
        end
      }
      temp_lines
    end
    once :ecpaat_lines
    
    def ecpaat_complete?
      temp_hash = ecpaat
      ECPAAT_HEADINGS.each do |heading|
        unless temp_hash.has_key?(heading)
          return false
        end
      end
      return true
    end
    once :ecpaat_complete?

    def ecpaat
      compute_ecpaat
      @ecpaat
    end

    def ecpaat_signature
      compute_ecpaat
      @ecpaat_signature
    end
    
    def visited_queues
      queues = []
      signature_lines.each do |sig|
        unless (queue = sig.queue).nil? || queues.include?(queue)
          queues << queue
        end
      end
      queues
    end
    once :visited_queues

    def primary_param
      if ppg.nil? || ppg == "0"
        nil
      else
        "#{queue_name},#{h_or_s},#{center_name},#{ppg}"
      end
    end

    def secondary_1_param
      if sec_1_ppg.nil? || sec_1_ppg == "0"
        nil
      else
      "#{sec_1_queue},#{sec_1_h_or_s},#{sec_1_center},#{sec_1_ppg}"
      end
    end

    def secondary_2_param
      if sec_2_ppg.nil? || sec_2_ppg == "0"
        nil
      else
        "#{sec_2_queue},#{sec_2_h_or_s},#{sec_2_center},#{sec_2_ppg}"
      end
    end

    def secondary_3_param
      if sec_3_ppg.nil? || sec_3_ppg == "0"
        nil
      else
        "#{sec_3_queue},#{sec_3_h_or_s},#{sec_3_center},#{sec_3_ppg}"
      end
    end

    def secondary_1
      get_call(sec_1_center, sec_1_queue, sec_1_h_or_s, sec_1_ppg)
    end
    once :secondary_1

    def secondary_2
      get_call(sec_2_center, sec_2_queue, sec_2_h_or_s, sec_2_ppg)
    end
    once :secondary_2

    def secondary_3
      get_call(sec_3_center, sec_3_queue, sec_3_h_or_s, sec_3_ppg)
    end
    once :secondary_3

    def secondaries
      [ secondary_1, secondary_2, secondary_3 ]
    end
    once :secondaries

    EMPTY_CRIT_SIT = Regexp.new(" {14}|-{14}|_{14}")

    def crit_sit
      if EMPTY_CRIT_SIT.match(problem_crit_sit)
        nil
      else
        problem_crit_sit
      end
    end

    # A convenience method to give back the usual form of
    # problem,branch,country for a call.
    def pbc
      (problem + ',' + branch + ',' + country).upcase
    end
    
    private

    def compute_ecpaat
      # We compute ecpaat once and ecpaat_signature is computed at the same
      # time.
      unless @ecpaat.nil?
        return
      end

      @ecpaat = { }
      @ecpaat_signature = { }
      last_signature = nil
      current_section = nil
      add_blank_line = false
      first_line = false
      all_text_lines.find_all { |text_line|
        if text_line.text_type == :normal
          text = text_line.text
          if (md = ECPAAT_REGEXP.match(text))
            current_section = get_current_section(md)
            @ecpaat_signature[current_section] = last_signature
            @ecpaat[current_section] = []
            text = md[8]
            add_blank_line = false
            first_line = true
            # logger.debug("CHC: ECPAAT found #{current_section}")
          end
          if current_section
            if BLANK_REGEXP.match(text)
              add_blank_line = true unless first_line
            else
              first_line = false
              if add_blank_line
                @ecpaat[current_section] << ""
              end
              @ecpaat[current_section] << text
              add_blank_line = false
            end
          end
        else                    # end of section
          current_section = nil
          if text_line.text_type == :signature
            last_signature = text_line
          end
        end
      }
    end

    def get_current_section(md)
      # logger.debug("CHC: get_current_section: md[2]=#{md[2].inspect}, md[3]=#{md[3].inspect}")
      index = (0 .. 5).select { |i| !md[i+2].nil? }.first
      ECPAAT_HEADINGS[index]
    end

    # Tries to retrieve a call from the database.  This is allowed to
    # return null if the call is not in the database
    def get_call(center, queue_name, h_or_s, ppg)
      if center = Cached::Center.find_by_center(center)
        if queue = center.queues.find_by_queue_name_and_h_or_s(queue_name, h_or_s)
          return queue.calls.find_by_ppg(ppg)
        end
      end
    end
  end
end
