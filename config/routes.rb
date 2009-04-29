ActionController::Routing::Routes.draw do |map|
  map.root :controller => "welcome"

  map.namespace :retain do |retain|
    retain.resources(:queues, :only => [ :index ]) do |queue|
      queue.resources(:calls, :only => [ :index, :show ])
    end
  end
#   map.resources :retain_solution_codes, :controller => 'retain/solution_codes'

#   map.resources :retain_service_given_codes, :controller => 'retain/service_given_codes'

#   map.resources :retain_service_action_cause_tuples

#   map.resources :combined_psars, :controller => 'combined/psars'

#   map.resources :retusers do |retuser|
#     retuser.resources :combined_psars, :controller => 'combined/psars'
#   end

#   # Feedback messages, etc.
#   map.resources :feedbacks do |feedback|
#     feedback.resources :feedback_notes
#   end

#   # Shows the user's favorite queues.
#   map.resources :combined_favorite_queues, :controller => 'combined/favorite_queues'

#   # Mapping between Queue and Person... Needs much work.
#   map.resources :combined_queue_infos, :controller => 'retain/queue_infos'

#   # Never has worked but will eventually display a PMR (instead of a call)
#   map.resources(:combined_pmrs,
#                 :controller => 'retain/pmrs',
#                 :member => {
#                   :addtime => :post,
#                   :addtxt  => :post
#                 })

#   # "Queue Status" -- my Techjump page
#   map.resources(:combined_qs,        :controller => 'retain/qs')
#   map.resources(:combined_customers, :controller => 'retain/customers')
#   map.resources(:combined_centers,   :controller => 'retain/centers')
#   map.resources(:combined_apars,     :controller => 'retain/apars')
#   map.resources(:combined_queues,    :controller => 'combined/queues')
  

#   # Call Update map.
#   map.retain_call_update('retain/call/:id',
#                          :controller => 'retain/call',
#                          :action => 'update',
#                          :method => :post)
  
#   # Reasonably well flushed out resources
#   map.resources(:combined_call,
#                 :controller => 'retain/call',
#                 :member => {
#                   :alter      => :post,
#                   :queue_list => :get,
#                   :ct         => :post })

#   map.resources(:combined_registration,
#                 :controller => 'retain/registration',
#                 :member => {
#                   :owner_list => :get
#                 })


#   # map.resources :retusers
#   map.resources :users

#   map.resources(:retain_formatted_panels,
#                 :controller => 'retain/formatted_panels')

#   # These Controllers are simple things just to poke retain
#   # Does a PMRQQ.  Debug and test. No useful info that I can find.
#   map.resources :retain_qq, :controller => 'retain/qq'
end
