# -*- coding: utf-8 -*-

module Retain
  # A model representing Retain pmrs.  See Cached::Pmrs for a list
  # of attributes that are cached.  Uses Retain::Pmpb to fetch data
  # from Retain so see it for what can be retrieved from Retain using
  # this model.  Also see Combined::Pmr for how the particulars on
  # how the Retain model and the Cached model are joined in this
  # particular instance.
  class Pmr < Retain::Base
    set_fetch_sdi Pmpb

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    def to_s
      "%s,%s,%s" % [ problem, branch, country ]
    end

    # Returns true if the pmr is a valid pmr.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(retain_user_connection_parameters, options)
      # logger.debug("in PMR valid?")
      new_options = {
        :problem => options[:problem],
        :branch => options[:branch],
        :country => options[:country],
        :group_request => [[ :comments ]]
      }
      pmr = new(retain_user_connection_parameters, new_options)
      begin
        comments = pmr.comments
      rescue Retain::SdiReaderError => e
        if e.sr == 115 && e.ex == 125
          raise Combined::PmrNotFound.new("%s,%s,%s" % [ pmr.problem, pmr.branch, pmr.country ])
        else
          raise e
        end
      end
    end
  end
end
