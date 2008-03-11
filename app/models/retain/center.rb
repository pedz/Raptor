module Retain
  class Center < Base
    set_fetch_sdi Pmbc

    def initialize(options = {})
      super(options)
    end

    def self.check_center(options)
      gr = { :group_request => [ :software_center_mnemonic ] }
      center = new(gr.merge(options))
      begin
        mnemonic = center.software_center_mnemonic
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end

  end
end
