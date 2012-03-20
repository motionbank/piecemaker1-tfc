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
sc = SetupConfiguration.new
sc.location_id = l.id
sc.time_zone = 'Berlin'
sc.s3_sub_folder = ''
sc.save
