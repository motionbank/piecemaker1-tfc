# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  piece_id   :integer
#  tag_type   :string(255)      default("normal")
#  account_id :integer
#

class Tag < ActiveRecord::Base
   has_and_belongs_to_many :events
   belongs_to :piece
end
