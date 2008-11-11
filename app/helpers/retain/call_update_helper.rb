module Retain
  module CallUpdateHelper
    def id_for(call_update, tag)
      "call_update_#{tag.gsub(/-/, '_')}_#{call_update.to_id}"
    end

    def html_tag(call_update, tag, options = { })
      options.merge({
        :id => id_for(call_update, tag),
        :class => "call-update-#{tag.gsub(/_/, '-')}"
      })
    end

    def send_mail_button(call_update)
      pmr = call_update.call.pmr
      id = id_for(call_update, "send-mail")
      hash = {
        :class => 'send-email-button',
        :id => id
      }
      if (mail = pmr.problem_e_mail.strip).blank?
        mail = nil
        hash[:disabled] = :disabled if mail.nil?
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

    def do_text_field(base, field, size, call_update)
      base.text_field field, html_tag(call_update, field.to_s, :size => size, :maxlength => size)
    end

    def do_select_field(psar, field, collection, value_method, text_method, call_update)
      psar.collection_select(field, collection, value_method, text_method,
                        { :prompt => false },
                         html_tag(call_update, field.to_s))
    end

    def do_label(label, for_field, call_update)
      content_tag :label, label, :for => id_for(call_update, for_field)
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
  end
end
