# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  module CallUpdateHelper
    def id_for(call_model, tag)
      "#{call_model_underscore(call_model)}_#{tag.gsub(/-/, '_')}_#{call_model.to_id}"
    end

    def html_tag(call_model, tag, options = { })
      options.merge({
        :id => id_for(call_model, tag),
        :class => "#{call_model_dash(call_model)}-#{tag.gsub(/_/, '-')}"
      })
    end

    def send_mail_button(call_model)
      pmr = call_model.call.pmr
      id = id_for(call_model, "send-mail")
      hash = {
        :class => 'send-email-button',
        :id => id
      }
      if pmr.problem_e_mail.nil? || (mail = pmr.problem_e_mail.strip).blank?
        mail = nil
        hash[:disabled] = :disabled
        text = "No Email Given"
      else
        add_page_setting(id,
                         {
                           :mail_addr => mail,
                           :subject => pmr.pbc,
                           :name => pmr.ecpaat["Customer Rep"].to_s.strip
                         })
        text = "Send Email"
      end
      content_tag :button, text, hash
    end

    def clear_boxes_button(call_model)
      id = id_for(call_model, "clear-boxes")
      hash = {
        :class => 'clear-boxes-button',
        :id => id
      }
      content_tag :button, "Clear Boxes", hash
    end

    def last_sg_span(call_model)
      content_tag(:span,
                  "Last SG was #{call_model.last_sg}",
                  html_tag(call_model, 'last-service-given-span'))
    end
    
    def to_owner_button(call_model)
      call = call_model.call
      pmr = call.pmr
      to_queue = nil
      person = nil
      if (person = pmr.resolver) && (queues = person.queues)
        to_queue = queues[0]
      elsif  (person = pmr.owner) && (queues = person.queues)
        to_queue = queues[0]
      end
      return if to_queue.nil? || (call.queue.to_param == to_queue.to_param)
      
      hash = {
        :value => to_queue.to_param,
        :id => id_for(call_model, 'setup-to-send-back'),
        :class => 'setup-to-send-back'
      }
      content_tag :button, "Queue back to #{person.name}", hash
    end

    def do_text_field(base, field, size, call_model, options = {})
      base.text_field(field, html_tag(call_model, field.to_s,
                                      options.merge(:size => size, :maxlength => size)))
    end

    def do_hidden_field(base, field, call_model, options = {})
      base.hidden_field(field, html_tag(call_model, field.to_s, options))
    end

    def do_select_field(base, field, collection, value_method, text_method, call_model)
      base.collection_select(field, collection, value_method, text_method,
                             { :prompt => false },
                             html_tag(call_model, field.to_s))
    end

    def do_select_field(psar, field, collection, value_method, text_method, call_model)
      psar.collection_select(field, collection, value_method, text_method,
                        { :prompt => false },
                         html_tag(call_model, field.to_s))
    end

    def do_label(label, for_field, call_model)
      content_tag(:label, label, :for => id_for(call_model, for_field), 
                  :class => "#{call_model_dash(call_model)}-#{for_field}-label")
    end

    def add_sac_tuples
      if @sac_tubples.nil?
        @sac_tuples = []
        Retain::ServiceActionCauseTuple.find(:all).each { |sac|
          @sac_tuples[sac.id] = sac.apar_required
        }
      end
      add_page_setting("sac_tuples", @sac_tuples)
    end

    private

    def call_model_underscore(call_model)
      # we have Retain::CallUpdate or Retain::CallFi5312 and we want
      # to underscore'ize that name but we don't want the leading
      # retain/ part of the name.
      call_model.class.to_s.underscore.sub(/^[^\/]*\//, '')
    end

    def call_model_dash(call_model)
      call_model_underscore(call_model).gsub('_', '-')
    end
  end
end
