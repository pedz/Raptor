# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Cached
  # = Retain PMR Model
  #
  # The model that represents the Problem Record from Retain.  The
  # table this model is stored in is <em>cached_pmrs</em>.
  class Pmr < Cached::Base
    ##
    # :attr: id
    # The primary key for the table.

    ##
    # :attr: problem
    # The problem number for the PMR.

    ##
    # :attr: branch
    # The branch for the PMR.

    ##
    # :attr: country
    # The country for the PMR.

    ##
    # :attr: customer_id
    # The id from the cached_customers table for the customer
    # associated with this PMR.

    ##
    # :attr: owner_id
    # The id from the cached_registrations table for the owner of this
    # PMR.

    ##
    # :attr: resolver_id
    # The id from the cached_registrations table for the resolver of
    # this PMR.

    ##
    # :attr: center_id
    # The id from the cached_centers table for the center that the
    # primary call of the PMR is in.

    ##
    # :attr: queue_id
    # The id from the cached_queues table for the queue that the
    # primary call for this PMR is on.

    ##
    # :attr: primary
    # The id from the cached_calls table for the primary call for this
    # PMR.

    ##
    # :attr: next_center_id
    # The id from the cached_centers table for the center given as the
    # next center for this PMR.

    ##
    # :attr: next_queue_id
    # The id from the cached_queues table for the queue given as the
    # next queue for this PMR.

    ##
    # :attr: severity
    # The severity of the PMR -- a field that is seldom if ever seen
    # by any interface that I know of.

    ##
    # :attr: component_id
    # The id from the cached_components table for the component listed
    # for this PMR.

    ##
    # :attr: problem_e_mail
    # The email address for the customer listed as the contact for
    # this PMR.

    ##
    # :attr: creation_date
    # The creation date (from Retain) for this PMR.

    ##
    # :attr: creation_time
    # The creation time (from Retain) for this PMR.  Note that as far
    # as I can tell, this is completely useless.  It given in the
    # timezone of the DR that created the PMR but there is no way of
    # knowing who the DR was as far as I have seen.

    ##
    # :attr: alteration_date
    # The last alteration date for the PMR.

    ##
    # :attr: alteration_time
    # The last alteration time for this PMR.

    ##
    # :attr: sec_1_queue
    # A PMR can have one primary and three secondaries.  After that,
    # backups are created.  The following twleve fields describe the
    # four tuple to uniquely identify the three secondary calls.
    # These fields come from Retain.

    ##
    # :attr: sec_1_center
    # See sec_1_queue

    ##
    # :attr: sec_1_h_or_s
    # See sec_1_queue

    ##
    # :attr: sec_1_ppg
    #

    ##
    # :attr: sec_2_queue
    # See sec_1_queue

    ##
    # :attr: sec_2_center
    # See sec_1_queue

    ##
    # :attr: sec_2_h_or_s
    # See sec_1_queue

    ##
    # :attr: sec_2_ppg
    # See sec_1_queue

    ##
    # :attr: sec_3_queue
    # See sec_1_queue

    ##
    # :attr: sec_3_center
    # See sec_1_queue

    ##
    # :attr: sec_3_h_or_s
    # See sec_1_queue

    ##
    # :attr: sec_3_ppg
    # See sec_1_queue

    ##
    # :attr: created_at
    # Rails normal created_at timestamp that is when the db record was
    # created.

    ##
    # :attr: updated_at
    # Rails normal updated_at timestamp.  Each time the db record is
    # saved, this gets updated.

    ##
    # :attr: last_alter_timestamp
    # Retain maintaines this last alter timestamp and a way to ask for
    # the lines of text since this last time stamp.

    ##
    # :attr: dirty
    # See Cached::Call#dirty

    ##
    # :attr: special_application
    # When set to 'E', this is an OEM PMR (how Hitachi PMRs use to
    # work).

    ##
    # :attr: last_fetched
    # See Cached::Call#last_fetched

    ##
    # :attr: queue_name
    # The queue name (from Retain) of the primary call for this PMR.

    ##
    # :attr: center_name
    # The center name (from Retain) of the primary call for this PMR.

    ##
    # :attr: ppg
    # The ppg for the primary call for this PMR.

    ##
    # :attr: h_or_s
    # The h_or_s field for the primary call for this PMR.

    ##
    # :attr: comments
    # A PMR has comments (which are also rarely seen).

    ##
    # :attr: hot
    # A Raptor flag that can be set via the user interface to flag the
    # PMR as hot for purposes of management attention.

    ##
    # :attr: business_justification
    # The business justification (a Raptor field) for marking the PMR
    # hot.

    ##
    # :attr: problem_crit_sit
    # The critical situation associated (if any) with this PMR.

    ##
    # :attr: deleted
    # The PMR has been purged from Retain (but is kept in the Raptor
    # database).

    ##
    # :attr: problem_status_code
    # The field that changes from OP for open to CL1L1 for closed,
    # etc.

    ##
    # :attr: expire_time
    # Set to 30.minutes.
    set_expire_time 30.minutes

    set_table_name "cached_pmrs"

    ##
    # :attr: calls
    # A has_many association to the Cached:Call entries that belong to
    # this PMR.
    has_many   :calls,        :class_name => "Cached::Call"

    ##
    # :attr: owner
    # A belongs_to association to the Cached::Registration for the
    # owner of the PMR.
    belongs_to :owner,        :class_name => "Cached::Registration"

    ##
    # :attr: resolver
    # A belongs_to association to the Cached::Registration for the
    # resolver of the PMR.
    belongs_to :resolver,     :class_name => "Cached::Registration"

    ##
    # :attr: customer
    # A belongs_to association to the Cached::Customer for the
    # customer of the PMR.
    belongs_to :customer,     :class_name => "Cached::Customer"

    ##
    # :attr: center
    # A belongs_to association to the Cached::Center where the primary
    # call for this PMR is currently locationed.
    belongs_to :center,       :class_name => "Cached::Center"

    ##
    # :attr: queue
    # A belongs_to asssociation to the Cached::Queue which contains
    # the primary call for this PMR.
    belongs_to :queue,        :class_name => "Cached::Queue"

    ##
    # :attr: primary_call
    # A belongs_to association to the Cached::Call which is the
    # primary call for this PMR.
    belongs_to :primary_call, :class_name => "Cached::Call", :foreign_key => "primary"

    ##
    # :attr: next_center
    # A belongs_to association to the Cached::Center that is marked as
    # the next center for the PMR.
    belongs_to :next_center,  :class_name => "Cached::Center"

    ##
    # :attr: next_queue
    # A belongs_to association to the Cached::Queue that is marked as
    # the next queue for this PMR.
    belongs_to :next_queue,   :class_name => "Cached::Queue"

    ##
    # :attr: psars
    # A has_many association to the Cached::Psar entries that
    # reference this PMR.
    has_many   :psars,        :class_name => "Cached::Psar"

    ##
    # :attr: scratch_pad_lines,
    # A has_many association of Cached::TextLine that is the scratch
    # pad lines for this PMR.
    has_many(:scratch_pad_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::SCRATCH_PAD}",
             :class_name => "Cached::TextLine",
             :order => "line_number ASC",
             :foreign_key => "pmr_id")

    ##
    # :attr: alterable_format_lines
    # A has_many association of Cached::TextLine that are used as the
    # alterable format lines (FA lines) for this PMR.
    has_many(:alterable_format_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::ALTERABLE_FORMAT}",
             :class_name => "Cached::TextLine",
             :order => "line_number ASC",
             :foreign_key => "pmr_id")

    ##
    # :attr: text_lines
    # A has_many association for the Cached::TextLine entries for the
    # main body of text for the PMR.
    has_many(:text_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::TEXT_LINE}",
             :class_name => "Cached::TextLine",
             :order => "line_number ASC",
             :foreign_key => "pmr_id",
	     :dependent => :destroy)

    ##
    # :attr: information_text_lines
    # A has_many association for the Cached::TextLine entries used as
    # the FI lines for the PMR.
    has_many(:information_text_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::INFORMATION_TEXT}",
             :class_name => "Cached::TextLine",
             :order => "line_number ASC",
             :foreign_key => "pmr_id")

    ##
    # Adds last_alter_timestamp to the except option and last_ct_time
    # to the methods option
    def as_json(options = { })
      if options.has_key? :except
        except = [ options[:except] ].push(:last_alter_timestamp).flatten.uniq
      else
        except = :last_alter_timestamp
      end
      methods_to_add = [:last_ct_time, :ecpaat, :ecpaat_signature]
      if options.has_key? :methods
        methods = [ options[:methods] ].push(methods_to_add).flatten.uniq
      else
        methods = methods_to_add
      end
      super(options.merge(:methods => methods, :except => except));
    end
    # set_as_json_default_options(:methods => [ :last_ct_time ])

    ##
    # With newer versions of Rails, this routine is not needed.  It
    # caches the text line from the database so they are only fetched
    # once per transaction.  (Newer Rails cached all database
    # queries.)
    def all_text_lines
      text_lines
    end
    once :all_text_lines
    
    ##
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

    ##
    # The etag sent to the browser for browser level cache
    # identification.
    def etag
      [ problem, branch, country, last_alter_timestamp ]
    end
    once :etag

    ##
    # A subset of all_text_lines that are system_inserted
    def system_inserted_lines
      all_text_lines.find_all { |text_line| text_line.text_type == :system_inserted }
    end
    once :system_inserted_lines
    
    ##
    # A further subset of system_inserted_lines of the service given
    # lines.
    def service_given_lines
      system_inserted_lines.find_all { |text_line| text_line.service_given }
    end
    once :service_given_lines
    
    ##
    # A subset of all_text_lines that are signature lines.  Note that
    # this does not return an array of Cached::TextLine but an array
    # of Retain::SignatureLine
    def signature_lines
      all_text_lines.find_all { |text_line|
        text_line.text_type == :signature
      }.map { |text_line|
        Retain::SignatureLine.new(text_line.text)
      }
    end
    once :signature_lines
    
    ##
    # Given a particular signature line type, return the signature
    # lines of that type.  Example types are "CE" or "CR", etc.
    def signature_line_stypes(stype)
      signature_lines.find_all { |sig| sig.stype == stype }
    end
    
    ##
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

    ##
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
          return created_at.to_datetime
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
    
    ##
    # Returns the last CT of the PMR.
    def last_ct
      signature_line_stypes('CT').last
    end
    once :last_ct

    ##
    # Returns the date and time from the last CT line of the PMR.
    def last_ct_time
      if (last = last_ct)
        last.date
      else
        create_time
      end
    end
    once :last_ct_time

    ##
    # age of the PMR in days
    def age
      # Note that DateTime does this subtraction correctly even if
      # they are different time zones.
      d = create_time
      logger.debug("create time is #{d.inspect} #{d.class.to_s}")
      if d.nil?
        DateTime.now
      else
        DateTime.now - create_time
      end
    end
    once :age

    ENVIRONMENT  = "environment|env".freeze
    CUSTOMER     = "customer rep".freeze
    PROBLEM      = "problem".freeze
    ACTION_TAKEN = "action taken".freeze
    ACTION_PLAN  = "action plan".freeze
    TESTCASE     = "testcase".freeze
    SUMMARY      = "summary".freeze
    ECPAAT_HEADINGS = [ "Environment",
                        "Customer Rep",
                        "Problem",
                        "Action Taken",
                        "Action Plan",
                        "Testcase",
                        "Summary"].freeze
    ##
    # A regular expression that matches the ECPAAT headings.
    ECPAAT_REGEXP = Regexp.new("^(" +
                               "(#{ENVIRONMENT})|" +
                               "(#{CUSTOMER})|" +
                               "(#{PROBLEM})|" +
                               "(#{ACTION_TAKEN})|" +
                               "(#{ACTION_PLAN})|" +
                               "(#{TESTCASE})|" +
                               "(#{SUMMARY})" +
                               "): *(.*)$", Regexp::IGNORECASE).freeze

    #
    # The Anderson tools puts a '.' on a line to create an empty line.
    # The regexp below is true if the whole line is blank or if the
    # initial character is a period followed by blanks.
    BLANK_REGEXP = Regexp.new("^[. ] *$").freeze
    
    ##
    # Returns a flat array of lines with the ECPAAT headings prepended
    # to the lines of each section.
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
    
    ##
    # Returns true if there is a valid entry for each of the ECPAAT
    # sections.
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

    ##
    # Returns a hash whose keys are the ECPAAT section names and whose
    # values are the lines for that section.  The lines start after
    # the section name and continue until the first blank line.
    def ecpaat
      compute_ecpaat
      @ecpaat
    end

    ##
    # Returns a hash whose keys are the ECPAAT section names and whose
    # values are the signature line of the update where the ECPAAT
    # entry was found.
    def ecpaat_signature
      compute_ecpaat
      @ecpaat_signature
    end
    
    ##
    # Returns the list of queues that this PMR has been to.
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

    ##
    # Returns the "param" string for the primary call for this PMR.
    def primary_param
      if ppg.nil? || ppg == "0"
        nil
      else
        "#{queue_name},#{h_or_s},#{center_name},#{ppg}"
      end
    end

    ##
    # Returns the "param" string for the first secondary.
    def secondary_1_param
      if sec_1_ppg.nil? || sec_1_ppg == "0"
        nil
      else
      "#{sec_1_queue},#{sec_1_h_or_s},#{sec_1_center},#{sec_1_ppg}"
      end
    end

    ##
    # Returns the "param" string for the second secondary.
    def secondary_2_param
      if sec_2_ppg.nil? || sec_2_ppg == "0"
        nil
      else
        "#{sec_2_queue},#{sec_2_h_or_s},#{sec_2_center},#{sec_2_ppg}"
      end
    end

    ##
    # Returns the "param" string for the third secondary.
    def secondary_3_param
      if sec_3_ppg.nil? || sec_3_ppg == "0"
        nil
      else
        "#{sec_3_queue},#{sec_3_h_or_s},#{sec_3_center},#{sec_3_ppg}"
      end
    end

    ##
    # Returns the first secondary for the PMR.
    def secondary_1
      get_call(sec_1_center, sec_1_queue, sec_1_h_or_s, sec_1_ppg)
    end
    once :secondary_1

    ##
    # Returns the second secondary for the PMR.
    def secondary_2
      get_call(sec_2_center, sec_2_queue, sec_2_h_or_s, sec_2_ppg)
    end
    once :secondary_2

    ##
    # Returns the third secondary for the PMR.
    def secondary_3
      get_call(sec_3_center, sec_3_queue, sec_3_h_or_s, sec_3_ppg)
    end
    once :secondary_3

    ##
    # Returns a array of the secondaries for the PMR.
    def secondaries
      [ secondary_1, secondary_2, secondary_3 ]
    end
    once :secondaries

    EMPTY_CRIT_SIT = Regexp.new(" {14}|-{14}|_{14}")

    ##
    # Returns the PMRs crit sit field or nil if it is "empty".
    # "empty" in this case can be a field filled with underscores or
    # other trash.
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
    
    # Returns true if the PMR has a valid OPC
    def valid_opc
      temp = self.opc
      temp && (temp.length > 11) && (temp[0,11] == self.service_request)
    end
    
    def hot?
      hot || priority == 1 || severity == 1 || crit_sit
    end

    private

    ##
    # Scans the PMR to find the ECPAAT lines.  The last entry for a
    # particular type is retained.
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
      line_count = 0
      all_text_lines.find_all { |text_line|
        if text_line.text_type == :normal
          text = text_line.text
          if (md = ECPAAT_REGEXP.match(text))
            current_section = get_current_section(md)
            @ecpaat_signature[current_section] = last_signature
            @ecpaat[current_section] = []
            text = md[ECPAAT_HEADINGS.length + 2]
            add_blank_line = false
            first_line = true
            line_count = 1
            # logger.debug("CHC: ECPAAT found #{current_section}")
          end
          if current_section
            if BLANK_REGEXP.match(text)
              add_blank_line = true unless first_line
            else
              first_line = false
              if add_blank_line
                line_count += 1
                @ecpaat[current_section] << ""
              end
              line_count += 1
              @ecpaat[current_section] << text
              add_blank_line = false
            end
            if line_count > 8
              current_section = nil
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

    
    ##
    # Returns which section, Environment, Customer, ..., that was
    # matched by the match data passed in.
    def get_current_section(md)
      # logger.debug("CHC: get_current_section: md[2]=#{md[2].inspect}, md[3]=#{md[3].inspect}")
      index = (0 ... ECPAAT_HEADINGS.length).select { |i| !md[i+2].nil? }.first
      ECPAAT_HEADINGS[index]
    end

    ##
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
