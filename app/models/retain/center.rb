# -*- coding: utf-8 -*-

module Retain
  class Center < Base
    set_fetch_sdi Pmbc

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    def self.valid?(retain_user_connection_parameters, options)
      # short circuit asking if "" is a valid center
      return false if options[:center].blank?
      return false if options[:center] == "000"
      new_options = {
        :center => options[:center],
        :group_request => [[ :software_center_mnemonic ]]
      }
      center = new(retain_user_connection_parameters, new_options)
      begin
        mnemonic = center.software_center_mnemonic
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
