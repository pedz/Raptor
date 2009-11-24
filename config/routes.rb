# -*- coding: utf-8 -*-

ActionController::Routing::Routes.draw do |map|
  map.resources :combined_hot_pmr_time, :controller => 'combined/hot_pmr_time'
  
  map.resources :retain_solution_codes, :controller => 'retain/solution_codes'

  map.resources :retain_service_given_codes, :controller => 'retain/service_given_codes'

  map.resources :retain_service_action_cause_tuples

  map.resources :combined_psars, :controller => 'combined/psars'

  map.resources :retusers do |retuser|
    retuser.resources :combined_psars, :controller => 'combined/psars'
  end

  # Feedback messages, etc.
  map.resources :feedbacks do |feedback|
    feedback.resources :feedback_notes
  end

  # Shows the user's favorite queues.
  map.resources :combined_favorite_queues, :controller => 'combined/favorite_queues'

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
                  :ct         => :post })

  map.resources(:combined_registration,
                :controller => 'retain/registration',
                :member => {
                  :owner_list => :get
                })


  # map.resources :retusers
  map.resources :users

  map.resources(:retain_formatted_panels,
                :controller => 'retain/formatted_panels')

  # These Controllers are simple things just to poke retain
  # Does a PMRQQ.  Debug and test. No useful info that I can find.
  map.resources :retain_qq, :controller => 'retain/qq'

  # The priority is based upon order of creation: first created ->
  # highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  # map.resources :products

  # Sample resource route with options:
  # map.resources :products, :member => { :short => :get, :toggle => :post },
  #    :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  # map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # You can have the root of your site routed with map.root --
  # just remember to delete public/index.html.
  map.root :controller => "welcome"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
