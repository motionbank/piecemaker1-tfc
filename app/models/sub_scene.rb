class SubScene < ActiveRecord::Base
  belongs_to :event
  scope :contains, lambda{|quer| {:conditions => ['title LIKE ? OR description LIKE ?', "%#{quer}%","%#{quer}%"]}}
  def self.convert_to_scenes
    SubScene.all.each do |sub|
      ee = Event.create(
        :parent_id => sub.event_id,
        :description => sub.description,
        :event_type => 'sub_scene',
        :title => sub.title,
        :happened_at => sub.happened_at,
        :created_at => sub.created_at,
        :updated_at => sub.updated_at
      )
    end
  end

  def parse_performers_and_give_to_parent
    old_performers = event.performers
    all_performers = self.event.piece.performers.map{|x| x.login}
    all_performers = all_performers.reject{|x| [nil,''].include?(x)}
    low_desc =  self.description ? self.description.downcase : ''
    low_title = self.title ? self.title.downcase : ''
    all_performers.each do |performer|
      search_term = /\b#{performer.downcase}\b/
      if old_performers && !old_performers.include?(performer)&&(low_desc =~ search_term || low_title =~ search_term)
        self.event.performers << performer
      end
    end
    self.event.performers = self.event.performers.sort if self.event.performers
    self.event.save
  end
  def video_start_time
    if event.video
      @evst ||= (happened_at - event.video_recorded_at).to_i
    else
      nil
    end
  end
  


end

# == Schema Information
#
# Table name: sub_scenes
#
#  id          :integer(4)      not null, primary key
#  title       :string(255)
#  description :text
#  happened_at :datetime
#  event_id    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

