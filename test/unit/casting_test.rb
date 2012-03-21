# == Schema Information
#
# Table name: castings
#
#  id           :integer(4)      not null, primary key
#  performer_id :integer(4)      not null
#  piece_id     :integer(4)      not null
#  is_original  :boolean(1)      default(TRUE)
#

require 'test_helper'

class CastingTest < ActiveSupport::TestCase
  Casting.send(:public, *Casting.protected_instance_methods)
  context 'a casting instance' do
    setup do
      @c = Casting.create(:user_id => 2,:piece_id => 21)
    end
    should 'be true' do
      assert @c
    end
  end
end

