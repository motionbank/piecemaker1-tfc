require 'test_helper'

class VideoRecordingTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: video_recordings
#
#  id         :integer(4)      not null, primary key
#  piece_id   :integer(4)
#  video_id   :integer(4)
#  primary    :boolean(1)      default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

