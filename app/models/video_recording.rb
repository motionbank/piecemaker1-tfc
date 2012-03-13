class VideoRecording < ActiveRecord::Base
  belongs_to :video
  belongs_to :piece
  
  def self.eliminate_dups
    vrs = all
    super_set = []
    vrs.each do |vr|
      set = vrs.select{|x| x.video_id == vr.video_id && x.piece_id == vr.piece_id}
      puts vr.id.to_s + ' ' + set.length.to_s
      if set.length > 1
        super_set << set.first
      end
    end
    super_set.each do |one|
      puts one.id
      one.destroy
    end
  end
end

# == Schema Information
#
# Table name: video_recordings
#
#  id         :integer(4)      not null, primary key
#  piece_id   :integer(4)
#  video_id   :integer(4)
#  primary    :boolean(1)      default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

