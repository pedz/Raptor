module Retain
  # Class created just so we can check if a queue is valid or not.
  
  class Cq < Base
    set_fetch_sdi Pmcs

    def initialize(options = {})
      super(options)
    end

    def self.check_queue(options)
      cq = Retain::Cq.new(options)
      begin
        hits = cq.hits # get the hits to see if the queue is valid
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
