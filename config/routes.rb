ActionController::Routing::Routes.draw do |map|
  # Feedback messages, etc.
  map.resources :feedbacks do |feedback|
    feedback.resources :feedback_notes
  end

  # Shows PSAR data
  map.resource  :retain_psar,              :controller => 'retain/psar'

  # Does a PMRQQ.  Debug and test. No useful info that I can find.
  map.resources :retain_qq,                :controller => 'retain/qq'

  # Mapping between Queue and Person... Needs much work.
  map.resources :combined_queue_infos,       :controller => 'retain/queue_infos'

  # Never has worked but will eventually display a PMR (instead of a call)
  map.resources(:combined_pmrs,
                :controller => 'retain/pmrs',
                :member => {
                  :alter => :post,
                  :queue_list => :get
                })

  # "Queue Status" -- my Techjump page
  map.resources :combined_qs,                :controller => 'retain/qs'

  # Reasonably well flushed out resources
  map.resources(:combined_call,
                :controller => 'retain/call',
                :member => {
                  :alter => :post,
                  :addtxt => :post,
                  :requeue => :post })
  map.resources(:combined_registration,
                :controller => 'retain/registration',
                :member => {
                  :owner_list => :get
                })

  map.resources :combined_queue,           :controller => 'retain/queue'
  map.resources :combined_favorite_queues, :controller => 'retain/favorite_queues'
  map.resources :retusers
  map.resources :users

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
  # map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  # map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
