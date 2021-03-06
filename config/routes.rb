Piecemaker::Application.routes.draw do

    match '/pref.:format' => 'users#pref', :as => :pref
    resources :users
    resources :usersessions
    match '/login' => 'usersessions#new', :as => :login
    match '/logout' => 'usersessions#destroy', :as => :logout
    match '/pieces/list' => 'pieces#list', :as => :pieces
    match 'home' => 'home#welcome', :as => :home
    match '/capture/rate/:rating/:id.:format' => 'capture#rate'
    match '/viewer/rate/:rating/:id.:format' => 'viewer#rate'
    match '/capture/rate_video/:rating/:id.:format' => 'capture#rate_video'
    match '/capture/new_event/:piece_id/:event_type.:format' => 'capture#new_event'
    match '/capture/new_sub_scene/:piece_id.:format' => 'capture#new_sub_scene'
    match '/capture/new_event_after/:piece_id/:event_type/:after_id.:format' => 'capture#new_event'
    match '/capture/new_auto_video_in/:piece_id.:format' => 'capture#new_auto_video_in'
    match '/video_upload/:id/:piece_id' => 'video#new'
    match '/video_viewer/:piece_id/:id' => 'viewer#viewer'
    match '/add_annotation/:piece_id/:id/:time.:format' => 'viewer#add_annotation'
    match '/add_sub_annotation/:piece_id/:id/:time.:format' => 'viewer#add_sub_annotation'
    match '/add_marker/:piece_id/:id/:time.:format' => 'viewer#add_marker'
    match '/edit_annotation/.:format' => 'viewer#edit_annotation'
    match '/edit_sub_annotation/.:format' => 'viewer#edit_sub_annotation'
    match '/video/index' => 'video#index'
    match '/video/new_list' => 'video#new_list'
    match ':controller/service.wsdl' => '#wsdl'
    match '/:controller(/:action(/:id))'
    match ':controller/:action.:format' => '#index'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  match '/capture/new_event/:piece_id/:event_type' => 'capture#new_event', :as => :new_event
  match '/capture/new_sub_scene/:piece_id' => 'capture#new_sub_scene', :as => :new_sub_scene

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
   root :to => 'home#welcome'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
