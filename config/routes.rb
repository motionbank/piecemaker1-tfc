Piecemakerlite::Application.routes.draw do
    
    match '/pref.:format' => 'users#pref', :as => :pref
    resources :users
    resources :usersessions
    match '/login' => 'usersessions#new', :as => :login
    match '/logout' => 'usersessions#destroy', :as => :logout
    match '/pieces/list' => 'pieces#list', :as => :pieces
    match 'home' => 'home#welcome', :as => :home
    match '/capture/rate/:rating/:id.:format' => 'capture#rate'
    match '/events/rate/:rating/:id.:format' => 'events#rate'
    match '/capture/rate_video/:rating/:id.:format' => 'capture#rate_video'
    match '/video_upload/:id1/:id2' => 'video#new'
    match '/video_viewer/:piece_id/:id' => 'video#viewer'
    match '/capture/pieces_for_account/:id/:key' => 'capture#piece_for_account'
    match '/add_annotation/:piece_id/:id/:time.:format' => 'events#add_annotation'
    match '/add_sub_annotation/:piece_id/:id/:time.:format' => 'events#add_sub_annotation'
    match '/add_marker/:piece_id/:id/:time.:format' => 'events#add_marker'
    match '/edit_annotation/.:format' => 'events#edit_annotation'
    match '/edit_sub_annotation/.:format' => 'sub_scene#edit_sub_annotation'
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
