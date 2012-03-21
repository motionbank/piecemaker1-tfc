# == Schema Information
#
# Table name: castings
#
#  id           :integer(4)      not null, primary key
#  user_id :integer(4)      not null
#  piece_id     :integer(4)      not null
#  is_original  :boolean(1)      default(TRUE)
#

class Casting < ActiveRecord::Base
  belongs_to :piece
  belongs_to :user
end

