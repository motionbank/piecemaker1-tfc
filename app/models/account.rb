class Account < ActiveRecord::Base
  def bucket_name
    "piecemakerlite-#{name}"
  end
  def s3_sub_folder
    name
  end
  def use_auto_video?
    SetupConfiguration.use_auto_video?
  end
  def self.setup_new(name)
    name = name.downcase
    puts "creating account #{name}"
    account = Account.create(
    :name => name,
    :time_zone => 'Berlin'
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
    puts "creating piece for #{name}"
    Piece.create(
    :title => 'First Piece',
    :short_name => 'New')
    puts "created piece for #{name}"

  end
  def self.accountize
    User.all.each do |x|
      x.account_id = 1
      x.save
    end
    Event.all.each do |x|
      x.account_id = 1
      x.save
    end
    Video.all.each do |x|
      x.account_id = 1
      x.save
    end
    SubScene.all.each do |x|
      x.account_id = 1
      x.save
    end 
    Piece.all.each do |x|
      x.account_id = 1
      x.save
    end
    DelayedJob.all.each do |x|
      x.account_id = 1
      x.save
    end
    Document.all.each do |x|
      x.account_id = 1
      x.save
    end  
    Message.all.each do |x|
      x.account_id = 1
      x.save
    end    
    MetaInfo.all.each do |x|
      x.account_id = 1
      x.save
    end    
    Note.all.each do |x|
      x.account_id = 1
      x.save
    end
    Photo.all.each do |x|
      x.account_id = 1
      x.save
    end
    Tag.all.each do |x|
      x.account_id = 1
      x.save
    end
  end
end
