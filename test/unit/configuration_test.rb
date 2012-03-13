require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: configurations
#
#  id               :integer(4)      not null, primary key
#  location_id      :integer(4)
#  time_zone        :string(255)
#  use_auto_video   :boolean(1)      default(FALSE)
#  created_at       :datetime
#  updated_at       :datetime
#  read_only        :boolean(1)      default(FALSE)
#  use_heroku       :boolean(1)      default(FALSE)
#  s3_sub_folder    :string(255)
#  default_piece_id :integer(4)
#  file_locations   :text
#

