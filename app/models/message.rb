# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  message    :text
#  from_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  account_id :integer
#

class Message < ActiveRecord::Base
  belongs_to :user
  def self.message_to(to,from,message)
    Message.create(
    :user_id => to,
    :from_id => from,
    :message => message)
  end
end
