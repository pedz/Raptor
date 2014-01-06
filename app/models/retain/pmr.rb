# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # === Retain PMR Model
  #
  # A model representing Retain pmrs.  See Cached::Pmrs for a list of
  # attributes that are cached and Combined::Pmr for how the
  # particulars on how the Retain model and the Cached model are
  # joined in this particular instance.
  class Pmr < Retain::Base
    ##
    # :attr: fetch_sdi
    # Set to Retain::Pmpb
    set_fetch_sdi Pmpb

    ##
    # :attr: fetch_sdi
    # Set to Retain::Ssbr
    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Returns problem,branch,country
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
        :group_request => [[ :creation_date ]]
      }
      pmr = new(retain_user_connection_parameters, new_options)
      begin
        cd = pmr.creation_date  # causes the fetch
        logger.debug("pmr in valid? is #{pmr}; class is #{pmr.class}")
        pmr                     # return entire result
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
