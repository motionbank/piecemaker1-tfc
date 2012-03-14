ActionController::Routing::Routes.draw do |map|
  #AdminData::Routing.connect_with map
  #map.resources :video

  #map.resources :events
map.pref '/pref.:format', :controller => 'users', :action => 'pref'
  map.resources :users
  map.resources :usersessions
  
map.login   '/login',  :controller => 'usersessions', :action => 'new'
map.logout   '/logout', :controller => 'usersessions', :action => 'destroy'
map.pieces  '/pieces/list', :controller => 'pieces', :action => 'list'
map.home  'home', :controller => "home", :action => 'welcome'

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
map.connect '/capture/rate/:rating/:id.:format', :controller => 'capture', :action => 'rate'
map.connect '/events/rate/:rating/:id.:format', :controller => 'events', :action => 'rate'
map.connect '/capture/rate_video/:rating/:id.:format', :controller => 'capture', :action => 'rate_video'
map.connect '/video_upload/:id1/:id2',:controller => 'video',:action => 'new'
map.connect '/video_viewer/:piece_id/:id.:format',:controller => 'video',:action => 'viewer'
#map.connect '/video_viewer/:piece_id.:format/:id',:controller => 'video',:action => 'viewer'
map.connect '/add_annotation/:piece_id/:id/:time.:format', :controller => 'events', :action => 'add_annotation'
map.connect '/add_sub_annotation/:piece_id/:id/:time.:format', :controller => 'events', :action => 'add_sub_annotation'
map.connect '/add_marker/:piece_id/:id/:time.:format', :controller => 'events', :action => 'add_marker'
map.connect '/edit_annotation/.:format', :controller => 'events', :action => 'edit_annotation'

map.connect '/edit_sub_annotation/.:format', :controller => 'sub_scene', :action => 'edit_sub_annotation'

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "home", :action => 'welcome'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id'
end
