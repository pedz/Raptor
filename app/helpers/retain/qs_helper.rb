module Retain
  module QsHelper
    def owner(call)
      retid = Logon.instance.signon
      pmr = call.pmr
      name = pmr.owner.name
      if name.blank?
        name = "blank"
      end
      css_class, title, editable = call.validate_owner
      td do
        if editable
          span(:id => "#{pmr.pbc}-pmr_owner_id",
               :class => "edit-name click-to-edit",
               :url => alter_combined_pmr_path(pmr),
               :options => {
                 :loadCollectionURL => owner_list_combined_registration_path(retid)
               }.to_json ) do
            title += ": Click to Edit"
            span :class => css_class, :title => title  do
              "#{name}"
            end
          end
        else
          span :class => css_class, :title => title  do
            "#{name}"
          end
        end
      end
    end

    def resolver(call)
      retid = Logon.instance.signon
      pmr = call.pmr
      name = pmr.resolver.name
      if name.blank?
        name = "blank"
      end
      css_class, title, editable = call.validate_resolver
      td do
        if editable
          span(:id => "#{pmr.pbc}-pmr_resolver_id",
               :class => "edit-name click-to-edit",
               :url => alter_combined_pmr_path(pmr),
               :options => {
                 :loadCollectionURL => owner_list_combined_registration_path(retid)
               }.to_json ) do
            title += ": Click to Edit"
            span :class => css_class, :title => title  do
              "#{name}"
            end
          end
        else
          span :class => css_class, :title => title  do
            "#{name}"
          end
        end
      end
    end

    def next_queue(call)
      retid = Logon.instance.signon
      pmr = call.pmr
      name = pmr.resolver.name
      if name.blank?
        name = "blank"
      end
      css_class, title, editable = call.validate_resolver
      td do
        if editable
          span(:id => "#{pmr.pbc}-pmr_resolver_id",
               :class => "edit-name click-to-edit",
               :url => alter_combined_pmr_path(pmr),
               :options => {
                 :loadCollectionURL => queue_list_combined_pmr_path(pmr)
               }.to_json ) do
            title += ": Click to Edit"
            span :class => css_class, :title => title  do
              "#{name}"
            end
          end
        else
          span :class => css_class, :title => title  do
            "#{name}"
          end
        end
      end
    end
    
    def td(hash = { })
      "<td#{hash.keys.map { |key| " #{key}='#{hash[key]}'"}}>" +
      yield +
      "</td>"
    end
    
    def span(hash = { })
      "<span#{hash.keys.map { |key| " #{key}='#{hash[key]}'"}}>" +
      yield +
      "</span>"
    end
  end
end
