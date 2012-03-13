# == Schema Information
#
# Table name: castings
#
#  id           :integer(4)      not null, primary key
#  performer_id :integer(4)      not null
#  piece_id     :integer(4)      not null
#  is_original  :boolean(1)      default(TRUE)
#  cast_number  :integer(4)      default(1)
#

class Casting < ActiveRecord::Base
  belongs_to :piece
  belongs_to :performer
end

