# == Schema Information
#
# Table name: performers
#
#  id         :integer(4)      not null, primary key
#  first_name :string(255)
#  last_name  :string(255)
#  short_name :string(255)
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer(4)
#  is_current :boolean(1)      default(TRUE)
#

class Performer < ActiveRecord::Base
  belongs_to :piece
  belongs_to :user
end

