class Account < ActiveRecord::Base
  def self.setup_new(name)
    puts "creating account #{name}"
    account = Account.create(
    :name => name
    )
    puts "account #{name} created"
    ActsAsTenant.current_tenant = account
    puts "creating new admin user in #{name}"
    admin = User.create(
    :login => 'admin',
    :password => 'admin',
    :password_confirmation => 'admin',
    :role_name => 'group_admin'
    )
    puts "admin user created for #{name}"
    puts "creating setup configuration for #{name}"
    SetupConfiguration.create(
      :time_zone => 'Berlin',
      :s3_sub_folder => '',
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
