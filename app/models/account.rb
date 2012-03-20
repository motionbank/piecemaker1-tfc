class Account < ActiveRecord::Base
  def self.setup_new_account(name)
    account = Account.create(
    :name => name
    )
    ActsAsTenant.current_tenant = account
    admin = User.create(
    :login => 'adminis',
    :password => 'adminis',
    :password_confirmation => 'adminis'
    )
    
    l = Location.new
    l.location = 'Home'
    l.save
    
    sc = SetupConfiguration.new
    sc.location_id = l.id
    sc.time_zone = 'Berlin'
    sc.s3_sub_folder = ''
    sc.save
    
  end
end
