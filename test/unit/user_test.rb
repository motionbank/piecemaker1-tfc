require 'test_helper'

class UserTest < ActiveSupport::TestCase
  User.send(:public, *User.protected_instance_methods)
  context 'a user instance' do
  end
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
#  role_name                 :string(255)
#  notes_on                  :boolean(1)      default(TRUE)
#  markers_on                :boolean(1)      default(TRUE)
#  refresh_pref              :integer(4)      default(0)
#  truncate                  :string(255)     default("more")
#  inherit_cast              :boolean(1)      default(FALSE)
#  last_assemblage_id        :integer(4)
#  last_login                :datetime
#

