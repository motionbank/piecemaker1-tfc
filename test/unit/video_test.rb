require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  Video.send(:public, *Video.protected_instance_methods)
  context 'a video instance' do
    setup do
      @piece      = Piece.create(
      :short_name => 'NAME',
      :id         => 4)
      @piece2      = Piece.create(
      :short_name => 'default',
      :id         => 5)
      @video1     = Video.create(
      :title      => '20100201_001_NAME.mp4')
      @video2     = Video.create(
      :title      => '201_hi.mp4')
      @video3     = Video.create(
      :title      => 'video_3')
      @piece.videos << @video1
      @piece.videos << @video2
      @video3.piece = @piece2
    end
    should 'remove default piece and give to piece' do
      @video3.give_to_piece(@piece2,@piece)
      assert_equal @video3.subjects,[@piece]
    end
    should 'return date prefix false if no prefix title' do
      assert !@video2.date_prefix
    end
    should  'return prefix if prefix' do
      assert_equal @video1.date_prefix, '20100201'
    end
    should  'return serial_no false if no serial_no' do
      assert !@video2.date_serial_number
    end
    should  'return serial_no' do
      assert_equal @video1.date_serial_number, '001'
    end
    should  'return title_string false if no title_string' do
      assert !@video2.title_string
    end
    should  'return title_string' do
      assert_equal @video1.title_string, 'NAME'
    end
    should 'return uses conventional name correctly' do
      assert @video1.uses_conventional_title?
      assert !@video2.uses_conventional_title?
    end
    should 'return false if not possible to determine' do
      assert !@video1.comes_before(@video2)
    end
    should 'return false if not comes before' do
      @video2.title = '20100101_002_NAME.mp4'
      assert !@video1.comes_before(@video2)
    end
    should 'return true if comes before' do
      @video2.title = '20100201_002_NAME.mp4'
      assert @video1.comes_before(@video2)
    end
  end
end


# == Schema Information
#
# Table name: videos
#
#  id          :integer(4)      not null, primary key
#  title       :string(255)
#  recorded_at :datetime
#  duration    :integer(4)
#  fn_local    :string(255)
#  fn_arch     :string(255)
#  fn_s3       :string(255)
#  vid_type    :string(255)     default("rehearsal")
#  rating      :integer(4)      default(0)
#  meta_data   :text
#  created_at  :datetime
#  updated_at  :datetime
#

