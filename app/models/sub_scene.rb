class SubScene < ActiveRecord::Base
  belongs_to :event
  scope :contains, lambda{|quer| {:conditions => ['title LIKE ? OR description LIKE ?', "%#{quer}%","%#{quer}%"]}}
  acts_as_tenant(:account)
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
  
  def promote_to_scene
    siblings = event.sub_scenes.select{|x| x.happened_at > happened_at}
    new_scene = Event.create(
    :title => title,
    :description => description,
    :piece_id => event.piece_id,
    :video_id => event.video_id,
    :happened_at => happened_at,
    :event_type => event.event_type,
    :performers => [],
    :created_by => event.created_by,
    :modified_by => event.modified_by)
    siblings.each do |sibling|
      new_scene.sub_scenes << sibling
    end
    self.destroy
    new_scene
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

