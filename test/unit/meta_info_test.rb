# == Schema Information
#
# Table name: meta_infos
#
#  id          :integer(4)      not null, primary key
#  created_at  :datetime
#  created_by  :string(255)
#  piece_id    :integer(4)
#  title       :string(255)
#  description :text
#

require 'test_helper'

class MetaInfoTest < ActiveSupport::TestCase
  MetaInfo.send(:public, *MetaInfo.protected_instance_methods)
  context 'a meta_info instance' do
    setup do
      @m = MetaInfo.create
    end
    should 'be true' do
      assert @m
    end
  end
end

