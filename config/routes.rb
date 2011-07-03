# -*- coding: utf-8 -*-

ActionController::Routing::Routes.draw do |map|
  map.resources :argument_types
  map.resources(:relationships,
                :collection => {
                  # For the new and edit pages, when the container
                  # name is set, an AJAX call is fired to this method
                  # to create a list of valid relationship_types
                  :container_name_set => :post,
                  # For the new and edit pages, when the relationship
                  # type is set, an AJAX call is fired to this method
                  # to create a list of objects that are valid
                  # elements.
                  :relationship_type_set => :post
                })
  map.resources :relationship_types
  map.resources :association_types
  map.resources :name_types
  map.resources :names
  map.resources :filters
  map.resources :levels
  
  # The order of these arguments need to match what is in the
  # argument_types table.  This could change and the controller could
  # split the fields apart and this would become more generic.
  map.calls("calls/:group/:levels/:filter/:view", :controller => 'calls', :action => 'index',
            :group => /[^\/]+/)
  map.calls("calls/:group/:levels/:filter",       :controller => 'calls', :action => 'index',
            :group => /[^\/]+/)
  map.calls("calls/:group/:levels",               :controller => 'calls', :action => 'index',
            :group => /[^\/]+/)
  map.calls("calls/:group",                       :controller => 'calls', :action => 'index',
            :group => /[^\/]+/)
  map.calls("calls",                              :controller => 'calls', :action => 'index')

  map.resources(:views) do |views|
    views.resources :elements
  end
  map.resources :widgets
  map.resources :retain_node_selectors
  map.resources :retain_nodes

  map.resources :hot_pmr_lists, :controller => 'hot_pmr_lists', :only => [ :index, :show ]
  map.namespace(:json) do |json|
    json.calls("calls/:group/:levels/:filter", :controller => 'calls', :group => /[^\/]+/ )
    json.views("views/:view", :controller => 'views')
    json.entities("entities", :controller => 'entities')
    json.resources(:favorite_queues)

    json.namespace(:cached) do |json_cached|
      json_cached.resources(:centers)
      json_cached.resources(:calls, :except => [:index])
      json_cached.resources(:components)
      json_cached.resources(:customers)
      json_cached.resources(:pmrs) do |json_cached_pmr|
        json_cached_pmr.resources(:calls)
        json_cached_pmr.resources(:psars)
        json_cached_pmr.resources(:text_lines)
      end
      json_cached.resources(:queues) do |json_cached_queue|
        json_cached_queue.resources(:calls)
      end
      json_cached.resources(:registrations) do |json_cached_registration|
        json_cached_registration.resources(:psars)
      end
    end

    json.namespace(:combined) do |json_combined|
      json_combined.resources(:centers)
      json_combined.resources(:components)
      json_combined.resources(:customers)
      json_combined.resources(:pmrs) do |json_combined_pmr|
        json_combined_pmr.resources(:text_lines)
      end
      json_combined.resources(:psars)
      json_combined.resources(:queues) do |jscon_combined_queue|
        jscon_combined_queue.resources(:calls)
      end
      json_combined.resources(:registrations)
    end
  end

  # Everything below here is from the old system...

  map.resources :hot_pmr_lists, :controller => 'hot_pmr_lists', :only => [ :index, :show ]
  map.resources :combined_hot_pmr_time, :controller => 'combined/hot_pmr_time'
  map.resources :retain_solution_codes, :controller => 'retain/solution_codes'
  map.resources :retain_service_given_codes, :controller => 'retain/service_given_codes'
  map.resources :retain_service_action_cause_tuples

  # This should be nested under retusers but I don't want to tackle
  # that right now.
  map.resources :combined_psars, :controller => 'combined/psars'

  map.resources :users do |user|
    user.resources :retusers
  end

  # Feedback messages, etc.
  map.resources :feedbacks do |feedback|
    feedback.resources :feedback_notes
  end

  # Shows the user's favorite queues.
  map.resources(:favorite_queues,
                :collection => {
                  :expanded => :get,
                  :sort => :post
                })

  # Mapping between Queue and Person... Needs much work.
  map.resources :combined_queue_infos, :controller => 'retain/queue_infos'

  # Never has worked but will eventually display a PMR (instead of a call)
  map.resources(:combined_pmrs,
                :controller => 'retain/pmrs',
                :member => {
                  :addtime => :post,
                  :addtxt  => :post
                })

  # "Queue Status" -- my Techjump page
  map.resources(:combined_qs,         :controller => 'retain/qs')
  map.resources(:combined_customers,  :controller => 'retain/customers')
  map.resources(:combined_centers,    :controller => 'retain/centers')
  map.resources(:combined_components, :controller => 'retain/components')
  map.resources(:combined_apars,      :controller => 'retain/apars')
  map.resources(:combined_queues,     :controller => 'combined/queues')
  

  # Call Update map.
  map.retain_call_update('retain/call/:id',
                         :controller => 'retain/call',
                         :action => 'update',
                         :method => :post)
  
  # Reasonably well flushed out resources
  map.resources(:combined_call,
                :controller => 'retain/call',
                :member => {
                  :alter      => :post,
                  :queue_list => :get,
                  :ct         => :post,
                  :dispatch   => :post })

  map.resources(:combined_registration,
                :controller => 'retain/registration',
                :member => {
                  :owner_list => :get
                })


  map.resources(:retain_formatted_panels,
                :controller => 'retain/formatted_panels')

  # These Controllers are simple things just to poke retain
  # Does a PMRQQ.  Debug and test. No useful info that I can find.
  map.resources :retain_qq, :controller => 'retain/qq'
  map.root :controller => "welcome"
end
