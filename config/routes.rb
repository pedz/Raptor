ActionController::Routing::Routes.draw do |map|
  map.resources :feedbacks do |feedback|
    feedback.resources :feedback_notes
  end
  # map.resources :feedbacks
  # map.resources :feedback_notes, :path_prefix => '/feedbacks/:feedback_id'

  map.resources :retain_pmrs, :controller => 'retain/pmrs'
  map.resources :retain_call, :controller => 'retain/call'
  map.resources :retain_psar, :controller => 'retain/psar'
  map.resources :retain_registration, :controller => 'retain/registration'
  map.retain_queue 'retain_queue/:queue_spec', :controller => 'retain/queue', :action => 'show'
  map.resources :favorite_queues
  map.resources :retusers
  map.resources :users

  # The priority is based upon order of creation: first created -> highest priority.

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
