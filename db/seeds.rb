User.create(
  :login => 'Administrator',
  :password => 'Administrator',
  :password_confirmation => 'Administrator',
  :role_name => 'group_admin')
Piece.create(
  :title => 'Default Piece',
  :short_name => 'DEFAULT',
  :is_active => false
  )
