require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: messages
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  message    :text
#  from_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

