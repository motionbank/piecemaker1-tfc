# == Schema Information
#
# Table name: meta_infos
#
#  id          :integer(4)      not null, primary key
#  created_at  :datetime
#  created_by  :string(255)
#  piece_id    :integer(4)
#  title       :string(255)
#  description :text
#

class MetaInfo < ActiveRecord::Base
  belongs_to :piece
  validates_presence_of :title
end
