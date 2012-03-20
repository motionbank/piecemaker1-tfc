# == Schema Information
#
# Table name: pieces
#
#  id           :integer(4)      not null, primary key
#  created_at   :datetime
#  title        :string(255)
#  updated_at   :datetime
#  modified_by  :string(255)
#  short_name   :string(255)
#  is_active    :boolean(1)      default(TRUE)
#

class Piece < ActiveRecord::Base
  has_many :castings, :dependent => :destroy
  has_many :performers, :through => :castings, :source => :user
  has_many :meta_infos, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  has_many :events, :dependent => :destroy, :order => 'happened_at'
  has_many :videos, :dependent => :destroy, :order => 'recorded_at'
 # has_many :recordings, :through => :video_recordings, :source => :video, :uniq => true, :order => :recorded_at, :include => {:events => [:sub_scenes,:tags,:notes,:video]}
  #has_many :small_recordings, :through => :video_recordings, :source => :video, :uniq => true, :order => :recorded_at, :include => {:events => [:sub_scenes,:tags,:notes,:video]}
 # has_many :ev_recordings, :through => :video_recordings, :source => :video, :uniq => true, :order => :recorded_at, :include => [:events]
 # has_many :clean_recordings, :through => :video_recordings, :source => :video, :uniq => true, :order => :recorded_at
 # has_many :short_recordings, :through => :video_recordings, :source => :video, :order => :recorded_at
  has_many :photos, :dependent => :destroy
  has_many :tags
    acts_as_tenant(:account)

  def latest_scene(pos = nil) #tested
    scenes = self.events.sort_by{|x| x.happened_at}.select{|x| x.event_type == 'scene'}
    scenes.reject!{|x| x.is_draft?}
    scenes.reject!{|x| x.happened_at > pos} if pos
    scenes.last
  end
  def empty_recordings
    videos.select{|x| x.events.length == 0}
  end
  def event_types
    Event.event_types
  end
  def owned_tags #tested
    self.tags.map{|x| x.name}
  end
  def word_statistics
    out_words = ['','the','of','and','or','at','not','it','is','was','in','to','a','an','with','be','as','but','that','this','you','i','what','if','for','have','are','we','he','she','br']
    out_words += performers.map{|x| x.login.downcase}
    word_frequencies = Hash.new(0)
    events.each do |event|
      title_array = []
      desc_array = []
      title_array = event.title.split(/[^a-zA-Z']/).map{|x| x.downcase}.reject{|x| out_words.include?(x)} if event.title
      desc_array = event.description.split(/[^a-zA-Z']/).map{|x| x.downcase}.reject{|x| out_words.include?(x)} if event.description
      title_array.each do |word|
        word_frequencies[word] += 1
      end
      desc_array.each do |word|
        word_frequencies[word] += 1
      end
      event.sub_scenes.each do |sub_scene|
        title_array = []
        desc_array = []
        title_array = sub_scene.title.split(/[^a-zA-Z']/).map{|x| x.downcase}.reject{|x| out_words.include?(x)} if sub_scene.title
        desc_array = sub_scene.description.split(/[^a-zA-Z']/).map{|x| x.downcase}.reject{|x| out_words.include?(x)} if sub_scene.description
        title_array.each do |word|
          word_frequencies[word] += 1
        end
        desc_array.each do |word|
          word_frequencies[word] += 1
        end
      end
    end
    word_frequencies = word_frequencies.sort_by {|x,y| y }
    word_frequencies.reverse!
  end
  def todays_videos_ids
    videos.select{|x| x.recorded_at.at_midnight == Time.now.at_midnight}.map{|x| x.id}
  end
  def active_events
    self.events.reject{|x| ['deleted'].include? x.state}
  end

  def add_performer(performer) #tested
    performers << performer unless performers.include? performer
  end
  def remove_performer(peformer) #tested
    performers.delete(peformer)
  end
  
  def date_list #tested
    dates = Array.new
    self.events.each do |event|
      unless dates.include?(event.happened_at.at_midnight)
        dates << event.happened_at.midnight
      end
    end
    dates
  end
  def recurring_titles
    
  end
  def set_locations
    #do this
  end
  
  def location_list #tested
    locations = []
    headlines = Event.where("piece_id = ? AND event_type = ?", self.id, 'headline')
    headlines.each do |event|
      if event.location && (! locations.first || event.location != locations.last[:location])
        locations << {:location => event.location,:date => event.happened_at} 
      end
    end
    locations.uniq
  end

end

