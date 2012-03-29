class Account < ActiveRecord::Base
  def bucket_name
    "piecemakerlite-#{name}"
  end
  def self.setup_new(name)
    name = name.downcase
    puts "creating account #{name}"
    account = Account.create(
    :name => name
    )
    puts "account #{name} created"
    ActsAsTenant.current_tenant = account
    puts "creating new admin user in #{name}"
    uname = "#{name}-admin"
    admin = User.create(
    :login => uname,
    :password => uname,
    :password_confirmation => uname,
    :role_name => 'group_admin'
    )
    puts "admin user created for #{name}"
    puts "username: #{uname}"
    puts "password: #{uname}"
    puts "creating setup configuration for #{name}"
    SetupConfiguration.create(
      :time_zone => 'Berlin',
      :s3_sub_folder => name,
      :file_locations => []
    )
    puts "created setup_configuration for #{name}"
    puts "creating piece for #{name}"
    Piece.create(
    :title => 'New Piece',
    :short_name => 'New')
    puts "created piece for #{name}"

  end
end
