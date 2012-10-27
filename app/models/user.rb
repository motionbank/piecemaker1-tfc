# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  login                     :string(40)
#  name                      :string(100)
#  email                     :string(100)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  role_id                   :integer          default(1)
#  role_name                 :string(255)
#  notes_on                  :boolean          default(TRUE)
#  markers_on                :boolean          default(TRUE)
#  refresh_pref              :integer          default(0)
#  truncate                  :string(255)      default("more")
#  inherit_cast              :boolean          default(FALSE)
#  last_login                :datetime
#  scratchpad                :text
#  first_name                :string(255)
#  last_name                 :string(255)
#  is_performer              :boolean          default(TRUE)
#  password_digest           :string(255)
#

class User < ActiveRecord::Base
  has_secure_password
  has_many :messages


  has_and_belongs_to_many :events, :order => :happened_at, :include => [:children,:tags,:notes,:video,:users]


  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false, :message => ' - There can\'t be two users with the same Username.'

  scope :performers, where(:is_performer => true)

  attr_accessible :login, :email, :password, :password_confirmation, :is_performer, :role_name, :scratchpad,:short_name, :first_name,:last_name

  before_create { generate_token(:remember_token) }

  def self.set_performer
    all.each do |u|
      u.is_performer = u.performer
      u.save
    end
  end


# this is for copying users after the migration
  # def self.create_new_ones
  #   User.all.each do |x|
  #     pass = x.login.length >=4 ? x.login : x.login+x.login
  #     User.create(
  #       :login => x.login,
  #       :password => pass,
  #       :password_confirmation => pass,
  #       :role_name => x.role_name,
  #       :is_performer => x.is_performer
  #       )
  #   end
  # end

  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  def store_from_params(params)
    self.refresh_pref = params[:refresh_rate] == 'Never' ? 0 : params[:refresh_rate].to_i
    self.notes_on = params[:noteshow] == 'on' ? true : false
    self.markers_on = params[:markershow] == 'on' ? true : false
    self.inherit_cast = params[:inherit_cast] == 'true' ? true : false
    self.truncate = params[:truncate] == 'true' ? 'more': 'none'
    save
  end


  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  protected


end

