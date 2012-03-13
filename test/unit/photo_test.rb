require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  Photo.send(:public, *Photo.protected_instance_methods)
  context 'a right instance' do
    setup do
      @p = Photo.create
    end
    should 'be true' do
      assert @p
    end
  end
end


# == Schema Information
#
# Table name: photos
#
#  id                   :integer(4)      not null, primary key
#  picture_file_name    :string(255)
#  picture_content_type :string(255)
#  picture_file_size    :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#  piece_id             :integer(4)
#  path                 :string(255)
#  has_thumb            :boolean(1)      default(FALSE)
#

