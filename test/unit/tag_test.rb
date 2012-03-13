# == Schema Information
#
# Table name: tags
#
#  id       :integer(4)      not null, primary key
#  name     :string(255)
#  piece_id :integer(4)
#  tag_type :string(255)     default("normal")
#

require 'test_helper'

class TagTest < ActiveSupport::TestCase
  Tag.send(:public, *Tag.protected_instance_methods)
  context 'a tag instance' do
    setup do

    end
    should 'be true' do
      assert true
    end
  end
end

