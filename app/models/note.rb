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

class Note < ActiveRecord::Base
  belongs_to :events
  acts_as_tenant(:account)
end

