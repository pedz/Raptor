
module Retain
  class SignatureLine
    cattr_accessor :logger, :instance_writer => false

  SIG_FLAG = ' (.)'     		# match  1
  SIG_NAME = '(......................)' # match  2
  SIG_COMP = '-(...........)'		# match  3
  SIG_CTR = '-L(...)'			# match  6
  SIG_QUE = '/(......)'			# match  7
  SIG_HONE = '-E(..........)'           # match  8
  SIG_BLAH = '((' + SIG_CTR + SIG_QUE + ')|' + SIG_HONE + ')'
  SIG_PRI = '-P(\d)'			# match  9
  SIG_SEV = 'S(\d)'			# match  10
  SIG_DATE = '-(\d\d/\d\d/\d\d-\d\d:\d\d)' # match  11
  SIG_PTYPE = ' (.)'			# match  12
  SIG_STYPE = '(..)'			# match 13
  SIGNATURE_PATTERN = Regexp.new(SIG_FLAG + SIG_NAME +
                                 SIG_COMP + SIG_BLAH + SIG_PRI +
                                 SIG_SEV + SIG_DATE + SIG_PTYPE + SIG_STYPE)
    def initialize(text)
      super()
      @text = text
      @md = SIGNATURE_PATTERN.match(text)
      # self.logger.debug("SGN: #{text}")
    end

    def to_s(tz)
      if @md
        " #{flag}#{name}-#{component}#{other}-P#{pri}S#{sev}-" +
          "#{date.new_offset(tz).strftime("%y/%m/%d-%H:%M")} #{ptype}#{stype}"
      else
        @text
      end
    end

    def flag
      @md[1] if @md
    end
    
    def name
      @md[2] if @md
    end

    def component
      @md[3] if @md
    end

    # This is the center/queue or the HONE thingy
    def other
      @md[4] if @md
    end

    def center
      @md[6] if @md
    end

    def queue_name
      @md[7].strip if @md
    end

    def queue(h_or_s = 'S')
      if @md && (qn = queue_name) != "------"
        (qn + "," + center + "," + h_or_s )
      end
    end

    def hone
      @md[8] if @md
    end
    
    def pri
      @md[9] if @md
    end

    def sev
      @md[10] if @md
    end

    def raw_date
      @md[11] if @md
    end

    def date
      if (rd = raw_date)
        year = 2000 + rd[0..1].to_i
        # second default to 0, timezone defaults to UTC
        DateTime.civil(year,
                       rd[3..4].to_i,
                       rd[6..7].to_i,
                       rd[9..10].to_i,
                       rd[12..13].to_i)
      end
    end

    def ptype
      @md[12] if @md
    end

    def stype
      @md[13] if @md
    end
  end
end
