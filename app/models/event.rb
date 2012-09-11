#class Array
#  def has_everyone
#    newself = self.select{|x| x.performers && x.performers[0] == 'Everyone'}
#  end
#end

class Event < ActiveRecord::Base
  def self.event_types
    %w[dev_notes discussion headline light_cue performance_notes scene sound_cue marker video sub_scene note]
  end
  #acts_as_audited
  #before_create :check_for_everyone
  #before_update :check_for_everyone, :except => 'unlock'              
  #has_many :sub_scenes, :dependent => :destroy, :order => 'happened_at'

  #has_many :notes, :dependent => :destroy
  belongs_to :piece
  serialize :performers
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :users

  has_many :subjects, :class_name => "Event",
    :foreign_key => "video_id"
  belongs_to :video, :class_name => "Event"

  has_many :children, :class_name => "Event", :foreign_key => "parent_id", :order => 'happened_at', :conditions => "event_type != 'note'"
  has_many :notes, :class_name => "Event", :foreign_key => 'parent_id', :order => 'happened_at', :conditions => "event_type = 'note'"
  belongs_to :parent, :class_name => "Event"
  
  scope :contains, lambda{|quer| {:conditions => ['title LIKE ? OR description LIKE ? OR performers LIKE ?', "%#{quer}%","%#{quer}%","%#{quer}%"],:include => :notes}}
  scope :highlighted, :conditions => "highlighted = '1'"
  scope :in_piece, lambda{|piece_id| {:conditions => ['piece_id = ?', "#{piece_id}"]}}
  scope :in_video, lambda{|video_id| {:conditions => ['video_id = ?', "#{video_id}"]}}
  scope :within_date_range, lambda{|date1,date2| {:conditions => ["happened_at between '#{date1}' and '#{date2}'"]}}
  scope :created_today, :conditions => "happened_at >= '#{Time.zone.now.at_midnight}'"
  scope :deleted, :conditions => "state = 'deleted'"
  scope :normal, :conditions => "state = 'normal'"
  scope :locked, :conditions => "locked != 'none'"
  scope :sub_events, :conditions => "event_type != 'note'"

  Event.event_types.each do |type|
    scope type+'s', :conditions => "event_type = '#{type}'"
  end
  
  delegate :recorded_at,:fn_arch,:fn_local,:fn_s3, :to => :video, :prefix => true
  delegate :tags, :to => :piece, :prefix => true

  def self.get_notes
    notes = Note.all
    notes.each do |note|
      if note.event
        Event.create(
          :parent_id => note.event_id,
          :description => note.note,
          :created_by => note.created_by,
          :modified_by => note.created_by,
          :created_at => note.created_at,
          :piece_id => note.event.piece_id,
          :performers => [],
          :event_type => 'note',
          :title => 'Note'
        )
      end
    end
  end
  def viewable?
    true#is_uploaded
  end

  def video_viewable?
    return false unless video_id && video
    video.viewable?
  end
  def tag_list #tested
    self.tags.collect{|x| x.name}.join(',')
  end
  
  def tag_names #tested
    tags.collect{|x| x.name.downcase}
  end
  def tagged_with_title? #tested
   title && tagged_with?(title)
  end

  def tagged_with?(tag) #tested
    tag_names.include?(tag.downcase)
  end

  def self.parse_tagstring(tag_params)#tested
    params_array = tag_params.present? ? tag_params.split(',').map{|x| x.strip} : []
  end
  
  def process_tags(tag_params)#tested
    params_array = Event.parse_tagstring(tag_params)    
    self.do_tag_process(params_array)
  end
  
  def get_tag_or_create(new_tag_name,title = nil)#tesed
    #Tag.where("name = ? and piece_id = ?",new_tag_name, piece_id)
    unless nn = Tag.where("name = ? and piece_id = ?",new_tag_name, piece_id).first
      nn = Tag.create(
        :name => new_tag_name,
        :tag_type => title ? 'title' : 'normal'
        )
      piece.tags << nn
    end
    nn
  end

  def do_event_changes(params,current_user,incremental = false)
    params[:event][:inherits_title] ||= false
    self.process_tags(params[:tags]) unless incremental
    params[:event][:performers] = params[:performers] || [] if needs_performers_field?
    params[:event][:description] ||= ''
    self.attributes = (params[:event])
    self.unlock
    self.get_performers_from_description
    self.add_title_from_tag(params)
    self.modified_by = current_user.login unless incremental
    self
  end

  
  def add_title_from_tag(params)
    if params[:tag_title] && params[:tag_title] != 'select a title from this list'
      self.title = params[:tag_title]
      tag = Tag.find_by_name(params[:tag_title])
      self.tags << tag
    end
  end
  def recorded_at
    happened_at
  end
  def end_time
    happened_at + dur
  end
  def video_start_time
    if video
      @evst ||= (happened_at - video.happened_at).to_i
    else
      nil
    end
  end

  def add_tag(new_tag)#tested
    unless self.tags.include?(new_tag)
      self.tags << new_tag
    end
  end

  def remove_tag
    
  end

  def do_tag_process(params_array)#tested
    self.tags.clear
    params_array.each do |params_tag|
      new_tag = self.get_tag_or_create(params_tag)
      self.add_tag(new_tag)   
    end
    #now i have to get rid of tags which aren't in the params list
      # self.tags(true).each do |tag|
      #   unless params_array.include?(tag.name)
      #     self.tags(true).delete(tag)
      #     logger.info {"************#{tag.name}  #{tag.events.first.title}"}
      #     tag.destroy if tag.events(true).length == 0
      #   end
      # end
  end
  
  def performer_picked?#tested
    !self.tag_names.select{|x| x.include?('likes!')}.empty?
  end
  
  def add_liker(user)#tested
    new_tag = self.get_tag_or_create("#{user}Likes!")
    self.add_tag(new_tag)
  end
  
  def needs_performers_field? #tested
    ['scene'].include?(self.event_type)
  end
  
  def tag_with_title #tested
    new_tag = self.get_tag_or_create(self.title,true)
    self.add_tag(new_tag)
    self.sub_scenes.each do |event|
      event.add_tag(new_tag)
    end
  end
  
  def self.pad_number(num) #tested
    string = ''
    if num < 100
      string << '0'
    end
    if num < 10
      string << '0'
    end
    string << num.to_s
  end


  def highlightable?#tested
    ['scene', 'light_cue', 'sound_cue'].include?(self.event_type)
  end

  def fixed_media_number #tested
    if video
      video.title#.to_i
    else
      SetupConfiguration.no_video_string
    end
  end
  
  def video_uploaded? #tested
    if self.video
      self.video.is_uploaded
    else
      false
    end
  end
  
  def make_draft(id_string = '') #tested
    self.state = "draft_of:#{id_string.to_s}" 
  end
  
  def is_draft? #tested
    if self.state
    self.state[0..8] == 'draft_of:'
    end
  end
  
  def make_normal #tested
    self.state = 'normal'
  end
  
  def locked?
    locked != 'none'
  end
  def locked_by
    locked == 'none' ? nil : locked
  end
  def unlock
    self.locked = 'none'
  end
  def lock(locker_name)
    self.locked = locker_name
  end
  
  def draft_original #tested
    return nil unless self.is_draft?
    orig_id = self.state
    orig_id.slice!(0..8)
    orig_id.to_i
  end
  
  def is_active? #needs a test
    !self.is_deleted? && !self.is_draft?
  end
  def is_deleted? #tested
    self.state == 'deleted'
  end
  
  def delet #tested
    self.state = 'deleted'
    self.save
  end
  def undelet #tested
    self.state = 'normal'
    self.save
  end
  def make_deleted #tested
      self.delet
  end
  def make_undeleted #tested
    self.undelet
  end

  
  def create_draft #tested
    new_event = self.dup
    new_event.make_draft(self.id)
    self.tags.each do |tag|
      new_event.tags << tag
    end
    new_event.save!
    new_event
  end
  def get_original#tested
    if self.is_draft?
      original = Event.find(self.draft_original)
    else
      self
    end
  end

  def set_attributes_from_params(params,current_user,current_piece)
    last_scene = current_user.inherit_cast ?  current_piece.latest_scene : nil
    after = params[:after] ? params[:after].gsub('.js','').to_i : nil
    if after ## new stuff for insert at
      logger.info {'************' + after.to_s}
      after_event = Event.find(after)
      self.happened_at = after_event.happened_at + 1
    else
      self.happened_at = Time.now
      after_event = nil
    end
    self.piece_id = current_piece.id
    self.performers = last_scene ? last_scene.performers : []
    self.event_type = params[:id]
    self.title = ''
    self.created_by = current_user.login
    if save
      make_draft(id.to_s)
      set_video_time_info
      save       
    end
    after_event
  end

  def self.update_original_from_draft(draft)
    original = draft.get_original
    original.title = draft.title
    original.performers = draft.performers
    original.description = draft.description
    original.event_type = draft.event_type
    original.video_id = draft.video_id
    original
  end
  def joined_performers(joiner)
    if performers
      performers.join(joiner)
    else
      ''
    end
  end

  def time_difference(other) #tested
    time = self.happened_at - other.happened_at
    time.to_i
  end

  def set_video_time_info
      video = piece.videos.select{|x| x.happened_at < happened_at}.last
      return nil unless video
      return nil if video.dur && video.recorded_at + video.dur < happened_at
      
      self.video_id = video.id
  end
  def unhide #tested
    self.state = 'normal'
    self.save
  end
  def hide #tested
    self.state = 'hidden'
    self.save
  end
  def is_hidden? #tested
    self.state == 'hidden'
  end


  def has_everyone? #tested
    return false unless performers
    return true if performers[0] == 'Everyone'
    return false unless performers.length > 4
    piece.performers.collect{|x| x.login.downcase}.sort == performers.collect{|x| x.downcase}.sort
  end
  
  
  
  def toggle_highlight! #tested
    self.update_attribute(:highlighted, !self.highlighted)
    self
  end
  
  def performer_everyone? #tested
    if self.performers && !self.performers.empty?
      self.performers[0] == 'Everyone'
    else
      false
    end
  end
  
  def performer_exclusive?(list_of_names)#tested
    if self.performers && !self.performers.empty?
      list_of_names.collect{|x| x.downcase} == self.performers.collect{|x| x.downcase}.sort
    else
      return false
    end
  end
  
  def performer_non_exclusive?(list_of_names)#tested
    list_of_names = list_of_names.map{|x| x.downcase}.sort
    if self.performers && !self.performers.empty?
      list_in_event = self.performers.sort.map{|x| x.downcase}
      (self.performers[0] != 'Everyone')&&((list_of_names & list_in_event) == list_of_names)
    else
      return false
    end
  end
  
  def performer_non_exclusive_with_everyone?(list_of_names)#tested
    list_of_names = list_of_names.map{|x| x.downcase}.sort
    if self.performers && !self.performers.empty?
      list_in_event = self.performers.sort.map{|x| x.downcase}
      (self.performers[0] == 'Everyone')||((list_of_names & list_in_event) == list_of_names)
    else
      return false
    end
  end
  
  def performer_semi_exclusive?(list_of_names)#tested #should return events in which any combination of the searched for performers are in but not other performers
    list_of_names = list_of_names.map{|x| x.downcase}.sort
    if self.performers && !self.performers.empty?
      list_in_event = self.performers.sort.map{|x| x.downcase}
      return false if list_in_event.length > list_of_names.length #gets rid of oversized events
      intersection = (list_of_names & list_in_event)
      return false if intersection.empty?
      list_in_event.each do |person|
        unless list_of_names.include?(person)
          return false
        end
      end
      true
    else
      return false
    end
  end
  
  def latest_scene #tested
    scenes = Event.where("piece_id = ? AND event_type = 'scene'",piece_id).order("happened_at")
    scenes.reject!{|x| !x.is_active?}
    scenes.reject!{|x| x.happened_at >= self.happened_at}
    scenes.last
  end
  def next_scene#tested
    @next_scene ||= Event.where("piece_id = ? AND event_type = 'scene'",piece_id).order("happened_at").select{|x| x.is_active?}.select{|x| x.happened_at > self.happened_at}.first
  end
  
  def in_which_video
    videos = piece.videos.sort_by{|x| x.recorded_at}
    before = videos.reject{|x| x.recorded_at > happened_at}.last
    return before if happened_at <= (before.recorded_at + before.duration)
    return nil
  end
  def check_for_reposition #tested
    vid = in_which_video
    if vid
      return if vid.id == video_id
      video_id = vid.id
    else
      return if !video_id
      video_id = nil
    end
  end


  def get_performers_from_description #tested
    all_performers = self.piece.performers.map{|x| x.login}
    all_performers = all_performers.reject{|x| [nil,''].include?(x)}
    low_desc =  self.description ? self.description.downcase : ''
    low_title = self.title ? self.title.downcase : ''
    all_performers.each do |performer|
      search_term = /\b#{performer.downcase}\b/
      if performers && !performers.include?(performer)&&(low_desc =~ search_term || low_title =~ search_term)
        self.performers << performer
      end
    end
    self.performers = self.performers.sort if self.performers
  end
  def insert_at_time(time)
    Event.where("happened_at = ?", time).each do |conflicting_event|
      conflicting_event.insert_at_time(time+1) #unless id == conflicting_event.id
    end
    self.happened_at = time
    self.save
  end
  def self.create_annotation(params,current_user,video,piece_id)
    event = create(
    :title => params[:event][:title],
    :event_type => params[:event][:event_type],
    :performers => params[:performers],
    :happened_at => params[:event][:happened_at],
    :video_id => params[:vid_id],
    :description => params[:event][:description],
    :modified_by => current_user.login,
    :piece_id => piece_id,
    :created_by => current_user.login
    )
    event.get_performers_from_description
    event.save
    event
  end

  def previous_scenes

    Event.where("piece_id = ? AND happened_at < ? AND state = 'normal' AND parent_id is NULL", piece_id, happened_at).order('happened_at')
    #piece.events.normal.select{|x| x.happened_at.at_midnight == happened_at.at_midnight && x.video == video && x.happened_at < happened_at && x.id != id}
  end
  def demote_to_sub_scene
    previous_scene = previous_scenes.last
    return false unless previous_scene
    self.parent_id = previous_scene.id
    save
    children.each do |child|
      child.parent_id = previous_scene.id
      child.save
    end
    self  
  end
    def promote_to_scene
    siblings = parent.children.select{|x| x.happened_at > happened_at}
    self.parent_id = nil
    save
    siblings.each do |sibling|
      sibling.parent_id = id
      sibling.save
    end
    self
  end
  def has_user_highlights?(user)
    users.include? user
  end
  def toggle_user_highlight(user)
    if has_user_highlights?(user)
      users.delete(user)
    else
      users << user
    end
  end

  def duration
    compute_duration
  end
  def compute_duration
    next_event = Event.where("piece_id = ?",piece_id).order('happened_at')
    next_event = next_event.select{|x| x.happened_at > happened_at}.first
    if video
      if next_event && next_event.video == video
        d = next_event.happened_at - happened_at
      else
        d = (video.recorded_at + video.duration - happened_at).to_i
      end
    else
      if next_event
        d = next_event.happened_at - happened_at
      else
        d = (happened_at.at_midnight + 1.day - happened_at).to_i
      end
    end
  end

  def set_video_title(piece)

    time = Time.now.strftime("%Y-%m-%d")
    last_dvd = piece.videos.last
    if last_dvd && last_dvd.title
      last_title = last_dvd.title.split('_')
      last_time = last_title[0]
      last_number = last_title[1].to_i
      if last_time == time #same day #increment serial number
        new_number = last_number + 1
      else #new day number = 1
        new_number = 1
      end

    else #no dvd make a new title
      new_number = 1
    end
    new_title = time + '_' + Event.pad_number(new_number)
    new_title << '_' + piece.short_name + '.mp4'
    self.title = new_title

  end

  def full_local_alias
    '/video/full/' + title
  end

  def online?
    file_path = Rails.root.to_s + '/public' + full_local_alias
    File.exists? file_path
  end

    def times
    tims = subjects.map{|x| [x.video_start_time,x.dur,x.id]}
    tims.sort_by{|x| x[0]}
    times = tims.to_json
  end

  protected

  def check_for_everyone #tested
    if self.needs_performers_field?
      self.performers = ['Everyone'] if self.has_everyone?
    end
  end
  
end


# == Schema Information
#
# Table name: events
#
#  id              :integer(4)      not null, primary key
#  created_at      :datetime
#  created_by      :string(255)
#  title           :string(255)
#  description     :text
#  event_type      :string(255)
#  modified_by     :string(255)
#  updated_at      :datetime
#  locked          :string(255)     default("none"), not null
#  performers      :text
#  media_time      :integer(4)
#  piece_id        :integer(4)
#  video_id        :integer(4)      default(0)
#  highlighted     :boolean(1)      default(FALSE)
#  inherits_title  :boolean(1)      default(FALSE)
#  state           :string(255)     default("normal")
#  rating          :integer(4)      default(0)
#  happened_at     :datetime
#


#from subscend
  # def parse_performers_and_give_to_parent
  #   old_performers = event.performers
  #   all_performers = self.event.piece.performers.map{|x| x.login}
  #   all_performers = all_performers.reject{|x| [nil,''].include?(x)}
  #   low_desc =  self.description ? self.description.downcase : ''
  #   low_title = self.title ? self.title.downcase : ''
  #   all_performers.each do |performer|
  #     search_term = /\b#{performer.downcase}\b/
  #     if old_performers && !old_performers.include?(performer)&&(low_desc =~ search_term || low_title =~ search_term)
  #       self.event.performers << performer
  #     end
  #   end
  #   self.event.performers = self.event.performers.sort if self.event.performers
  #   self.event.save
  # end
  # def video_start_time
  #   if event.video
  #     @evst ||= (happened_at - event.video_recorded_at).to_i
  #   else
  #     nil
  #   end
  # end