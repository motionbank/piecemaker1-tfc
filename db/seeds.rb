User.create(
  :login => 'admin',
  :password => 'admin',
  :password_confirmation => 'admin',
  :role_name => 'group_admin')
l = Location.create(
  :location => 'Home')
p = Piece.create(
  :title => 'Default Piece',
  :short_name => 'DEFAULT'
  )  
SetupConfiguration.create(
  :location_id => l.id,
  :time_zone => 'Berlin',
  :s3_sub_folder => '',
  :file_locations => [])

