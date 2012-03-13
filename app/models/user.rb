require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  has_many :logins
  has_many :messages
  has_one :performer
  has_and_belongs_to_many :events, :order => :happened_at, :include => [:sub_scenes,:tags,:notes,:video,:users]
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false, :message => ' - There can\'t be two users with the same Username.'
  validates_format_of       :login,    :with => RE_LOGIN_OK, :message => MSG_LOGIN_BAD


  #validates_presence_of     :email
  #validates_length_of       :email,    :within => 6..100 #r@a.wk
  #validates_uniqueness_of   :email,    :case_sensitive => false
  #validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :performer, :role_name, :scratchpad


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
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
  protected


end


# == Schema Information
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(40)
#  name                      :string(100)
#  email                     :string(100)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  role_id                   :integer(4)      default(1)
#  performer                 :boolean(1)      default(FALSE)
#  role_name                 :string(255)
#  notes_on                  :boolean(1)      default(TRUE)
#  markers_on                :boolean(1)      default(TRUE)
#  refresh_pref              :integer(4)      default(0)
#  truncate                  :string(255)     default("more")
#  inherit_cast              :boolean(1)      default(FALSE)
#  last_assemblage_id        :integer(4)
#  last_login                :datetime
#

