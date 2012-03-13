require 'test_helper'

class SubSceneTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: sub_scenes
#
#  id          :integer(4)      not null, primary key
#  title       :string(255)
#  description :text
#  happened_at :datetime
#  event_id    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

