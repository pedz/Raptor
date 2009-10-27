# -*- coding: utf-8 -*-

module Retain
  # Class created just so we can check if a queue is valid or not.
  # This class now has no real point since queue now uses PMCS.
  class Cq < Base
    set_fetch_sdi Pmcs

    def initialize(options = {})
      super(options)
    end

    def self.valid?(options)
      # short circuit asking if queue_name or center is blank
      return false if options[:queue_name].blank? || options[:center].blank?
      cq = Retain::Cq.new(options)
      begin
        hit_count = cq.hit_count # get hit_count to see if the queue is valid
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
