
module Retain
  class SignatureLine
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
      @md = SIGNATURE_PATTERN.match(text)
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

    def center
      @md[6] if @md
    end

    def queue
      @md[7] if @md
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

    def date
      @md[11] if @md
    end

    def ptype
      @md[12] if @md
    end

    def stype
      @md[13] if @md
    end
  end
end
