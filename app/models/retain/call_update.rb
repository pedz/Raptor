# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Retain
  # == Retain Call Update model
  #
  # Not a normal retain model.  This is a model used to update a call.
  # It is in the models directory because it is used with views to
  # create the update forms used in the combined qs and combined calls
  # pages.  (ok... but why is it called "Retain::CallUpdate and not
  # just CallUpdate?)
  class CallUpdate

    attr_reader   :call
    attr_accessor :update_pmr, :update_type, :do_ct, :do_p8, :newtxt, :add_time
    attr_accessor :new_queue, :new_priority, :service_given
    attr_accessor :psar_update, :do_ca
    attr_accessor :hot, :business_justification
    
    def initialize(call)
      # Rails.logger.debug("call_update initialize")
      @call = call
      @update_type = "addtxt"
      @update_pmr = true
      @do_ct = true
      @do_p8 = call.pmr.p8pmr?
      @do_ca = false
      @add_time = true
      @psar_update = PsarUpdate.new(75, 57, 50, call.priority, 9, 0, 30)
      @new_queue = call.queue.to_param
      @new_priority = call.priority
      @service_given = 99
      @pmr = call.pmr
      @hot = @pmr.hot
      @business_justification = @pmr.business_justification
      @newtxt = create_new_text
    end

    def last_sg
      sg_lines = @pmr.service_given_lines
      if sg_lines.empty?
        "NG"
      else
        sg_lines.last.service_given
      end
    end

    def to_id
      @_to_id ||= @call.to_id
    end

    def id
      @_id ||= @call.id
    end
    
    def to_param
      @_to_param ||= @call.to_param
    end

    private

    def create_new_text
      ecpaat = @pmr.ecpaat
      Rails.logger.debug(ecpaat.keys)
      signatures = @pmr.ecpaat_signature
      txt = ""
      Cached::Pmr::ECPAAT_HEADINGS.each do |heading|
        case heading

        # add if missing
        when "Environment", "Customer Rep", "Testcase"
          txt += "#{heading}: \n\n" unless ecpaat.has_key?(heading)

        # add if missing or if more than two weeks old
        when "Problem"
          if ecpaat.has_key?(heading)
            text_line = signatures[heading]
            signature = Retain::SignatureLine.new(text_line.text)
            if signature.date && (signature.date < 2.weeks.ago)
              txt += "#{heading}: #{fix_text(ecpaat[heading])}\n\n"
            end
          else
            txt += "#{heading}: \n\n"
          end

        # Always add
        when "Action Taken", "Action Plan"
          txt += "#{heading}: \n\n"

        # Never add
        when "Summary"
        end
      end
      txt
    end

    # Mostly does join("\n") but trims off space at the end of the
    # lines.
    def fix_text(lines)
      lines.join("\n").gsub(/ +$/, "")
    end
  end
end
