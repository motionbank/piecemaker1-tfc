class Message < ActiveRecord::Base
  belongs_to :user
  def self.message_to(to,from,message)
    Message.create(
    :user_id => to,
    :from_id => from,
    :message => message)
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

