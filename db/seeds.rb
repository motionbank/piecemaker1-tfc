User.create(
  :login => 'Administrator',
  :password => 'Administrator',
  :password_confirmation => 'Administrator',
  :role_name => 'group_admin')
l = Location.create(
  :location => 'Home')
p = Piece.create(
  :title => 'Default Piece',
  :short_name => 'DEFAULT',
  :is_active => false
  )  
Configuration.create(
  :location_id => l.id,
  :time_zone => 'Berlin',
  :s3_sub_folder => '',
  :default_piece_id => p.id,
  :file_locations => [])

