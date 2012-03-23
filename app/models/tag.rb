# == Schema Information
#
# Table name: tags
#
#  id       :integer(4)      not null, primary key
#  name     :string(255)
#  piece_id :integer(4)
#  tag_type :string(255)     default("normal")
#

class Tag < ActiveRecord::Base
   has_and_belongs_to_many :events
   belongs_to :piece
   #acts_as_tenant(:account)
end
