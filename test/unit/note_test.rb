# == Schema Information
#
# Table name: notes
#
#  id           :integer(4)      not null, primary key
#  created_at   :datetime
#  created_by   :string(255)
#  note         :text
#  event_id     :integer(4)
#  img          :string(255)
#  updated_at   :datetime
#  private_note :string(255)
#

require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  Note.send(:public, *Note.protected_instance_methods)
  context 'a note instance' do
    setup do
      @n = Note.create
    end
    should 'be true' do
      assert @n
    end
  end
end

