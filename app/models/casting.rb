# == Schema Information
#
# Table name: castings
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  piece_id    :integer          not null
#  is_original :boolean          default(TRUE)
#  cast_number :integer          default(1)
#  updated_at  :datetime
#

class Casting < ActiveRecord::Base
  belongs_to :piece
  belongs_to :user
end

