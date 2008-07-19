module Cached
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
             :foreign_key => "pmr_id")
    has_many(:information_text_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::INFORMATION_TEXT}",
             :class_name => "Cached::TextLine",
             :order => "line_number ASC",
             :foreign_key => "pmr_id")

    def all_text_lines
      to_combined.text_lines
    end
    once :all_text_lines
    
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
    
    # The creation_date and creation_time appear to be from the
    # perspective of the person who opened the PMR.  To get that back
    # to UTC would be really hard.  So, we find the first CE entry and
    # use its date.
    def create_time
      if (sig = signature_line_stypes('CE')).empty?
        unless tz = customer.tz
          tz = 0
        end
        # should never be true but just in case.
        cd = self.creation_date
        ct = self.creation_time
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
    
    def ecpaat
      h = { }
      current_section = nil
      add_blank_line = false
      first_line = false
      all_text_lines.find_all { |text_line|
        if text_line.text_type == :normal
          text = text_line.text
          if (md = ECPAAT_REGEXP.match(text))
            current_section = get_current_section(md)
            h[current_section] = []
            text = md[8]
            add_blank_line = false
            first_line = true
            logger.debug("CHC: ECPAAT found #{current_section}")
          end
          if current_section
            if BLANK_REGEXP.match(text)
              add_blank_line = true unless first_line
            else
              first_line = false
              if add_blank_line
                h[current_section] << ""
              end
              h[current_section] << text
              add_blank_line = false
            end
          end
        else                    # end of section
          current_section = nil
        end
      }
      h
    end
    once :ecpaat

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

    private

    def get_current_section(md)
      logger.debug("CHC: get_current_section: md[2]=#{md[2].inspect}, md[3]=#{md[3].inspect}")
      index = (0 .. 5).select { |i| !md[i+2].nil? }.first
      ECPAAT_HEADINGS[index]
    end

  end
end
