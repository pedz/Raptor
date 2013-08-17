# -*- coding: utf-8 -*-
#
# Copyright 2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Retain
  class PmrOpc
    def initialize(pmr)
      @pmr = pmr
    end

    def to_id
      @_to_id ||= @pmr.to_id
    end

    def id
      @_id ||= @pmr.id
    end
    
    def to_param
      @_to_param ||= @pmr.to_param
    end

    # Returns text, do_fade
    # text is an array of lines
    # do_fade is a boolean
    def update(opc_options)
      pmr_options = @pmr.to_options
      do_fade = true
      text = []
      base_results = "x" * 46   # a string of 46 x's

      suffix = "\x0B"
      opc_group_id = opc_options[:opc_group_id]
      start = DateTime.strptime(opc_options[:start], "%FT%H:%M:%S.%L%Z")

      # If the question type is 'T', the set of answers is the target
      # components.
      #
      # If the question code is blank, it is part of the first field.
      # The first field starts at character 15 and is 46 x's with the
      # answers to the base questions laid over the x's starting at
      # column "encoding sequence" * 3 for 3 characters -- except (it
      # seems) if the question type is T in which case, it consumes 4
      # characters left justified and space filled.
      #
      # The fields end with a 0x0B character.
      #
      # The opc_group_id is added in with an appropriate white space
      # (the left most digit is in column 1122 and the entire field is
      # 1152 characters long.
      #
      optional_questions = opc_options[:kv].map do |h|
        key = h['key']
        value = h['value']
        encode = h['encode'].to_i
        type = h['type']
        
        # disabled question
        next if value == '' || value.nil?

        # base question
        if key == ''
          if type == 'T'
            value = '%-4s' % value
          end
          base_results[(encode * 3), value.length] = value
          next
        end
        
        if encode < 0
          case value
          when 'user_time'
            value = (Time.now - start.to_time).to_i.to_s

          when 'user_name'
            value = opc_options[:user_name]

          when 'get_date'
            value = start.strftime("%F")

          end
        end
        key + value + suffix
      end.join('')
      s = (@pmr.service_request +
            opc_options[:qset] +
            base_results + suffix +
            optional_questions )
      s = "%-1122s" % s
      s += "%-30s" % opc_group_id

      pmr_options[:opc] = s
      pmpu = Retain::Pmpu.new(opc_options[:retain_params], pmr_options)
      fields = Retain::Fields.new
      pmpu.sendit(fields)
      if pmpu.rc != 0
        do_fade &= (pmpu.error_class != :error)
        text.push(sdi_error_mess(pmpu, "OPC"))
      else
        text.push(mess("OPC Completed"))
      end
      @pmr.mark_all_as_dirty
      return text, do_fade
    end

    private
    
    # Yes... these are copy and paste -- YUK!!!
    def mess(msg, sdi_class = :normal)
      {
        css_class: 'sdi-' + sdi_class.to_s,
        msg: msg
      }
    end

    def sdi_error_mess(sdi, request)
      err_text = "#{request}: #{sdi.error_message}"
      mess(err_text, sdi.error_class)
    end
  end
end
