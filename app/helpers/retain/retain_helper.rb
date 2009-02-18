module Retain
  module RetainHelper
    def fixed_width_span(locals)
      render(:partial => "shared/retain/fixed_width_span", :locals => locals)
    end

    def add_fixed_width_span(binding, locals)
      concat(fixed_width_span(locals), binding)
    end

    def common_display_pmr_comments(binding, call)
      add_page_setting("comments_#{call.to_id}",
                       {
                         :url => alter_combined_call_path(call)
                       })
      span(binding,
           :id => "comments_#{call.to_id}",
           :class => "edit-name") do |binding|
        concat(call.comments, binding)
      end
    end
    
    def common_display_pmr_owner(binding, call)
      retid = Logon.instance.signon
      pmr = call.pmr
      hash = call.validate_owner(signon_user)
      if hash[:editable]
        add_page_setting("pmr_owner_id_#{call.to_id}",
                         { 
                           :url => alter_combined_call_path(call),
                           :options => {
                             :loadCollectionURL => owner_list_combined_registration_path(retid)
                           }
                         })
        span(binding,
             :id => "pmr_owner_id_#{call.to_id}",
             :class => "collection-edit-name click-to-edit-button") do |binding|
          add_fixed_width_span(binding, hash)
        end
      else
        hash[:css_class] += " not-editable"
        add_fixed_width_span(binding, hash)
      end
    end

    def common_display_pmr_resolver(binding, call)
      retid = Logon.instance.signon
      pmr = call.pmr
      hash = call.validate_resolver(signon_user)
      if hash[:editable]
        add_page_setting("pmr_resolver_id_#{call.to_id}",
                         {
                           :url => alter_combined_call_path(call),
                           :options => {
                             :loadCollectionURL => owner_list_combined_registration_path(retid)
                           }
                         })
        span(binding,
             :id => "pmr_resolver_id_#{call.to_id}",
             :class => "collection-edit-name click-to-edit-button") do
          add_fixed_width_span(binding, hash)
        end
      else
        hash[:css_class] += " not-editable"
        add_fixed_width_span(binding, hash)
      end
    end

    def common_display_pmr_next_queue(binding, call)
      pmr = call.pmr
      hash = call.validate_next_queue(signon_user)
      if hash[:editable]
        add_page_setting("next_queue_#{call.to_id}",
                         {
                           :url => alter_combined_call_path(call),
                           :options => {
                             :loadCollectionURL => queue_list_combined_call_path(call)
                           }
                         })
        span(binding,
             :id => "next_queue_#{call.to_id}",
             :class => "collection-edit-name click-to-edit-button") do
          add_fixed_width_span(binding, hash)
        end
      else
        hash[:css_class] += " not-editable"
        add_fixed_width_span(binding, hash)
      end
    end

    def psar_button
      button_url('PSAR',
                 combined_psars_path(:psar_start_date => Time.previous_saturday.strftime("%Y%m%d")))
    end

    def registration_button
      button_url("Registration", signon_user)
    end
  end
end
