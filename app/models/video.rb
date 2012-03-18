class Video < ActiveRecord::Base
  
  MOVIE_EXTENSIONS = %w[mov mp4 m4v flv]
  
  #belongs_to :event
  belongs_to :piece
  has_many :events,:dependent => :nullify, :order => :happened_at,:conditions => "state = 'normal'"
  scope :active, :conditions => "state = 'normal'"


  after_save :rename_files_on_title_change###################


  def rename_files_on_title_change###################
    if self.title_changed?
     logger.info '******* title changed moving files'
   end
  end
  def update_from_params(params)
    #self.title = params[:title].split('.').first
    self.fn_s3 = '.' + params[:title].split('.').last
    save
  end
  def source_string
    sources = [] 
    if fn_local
      sources << fn_local
    else
      sources << ''
    end
    if fn_s3
      sources << fn_s3
    else
      sources << ''
    end
    if fn_arch
      sources << fn_arch
    else
      sources << ''
    end
    sources.join(',')
  end
  def mark_in(place)
    logger.info '******* trying to mark'
    marker = '.mp4'
    case place
    when 'local'
      self.fn_local = marker
      save
    when 's3'
      self.fn_s3    = marker
      save
    when 'archive'
      self.fn_arch  = marker
      save
    end
  end
  def mark_not_in(place)
    marker = nil
    case place
    when 'local'
      self.fn_local = marker
      save
    when 's3'
      self.fn_s3    = marker
      save
    when 'archive'
      self.fn_arch  = marker
      save
    end
  end
  def full_s3_path
    x = self.s3_path.split('.')
    x[1] = x[1] == 'flv' ? 'flv' : 'mp4'
    "#{x[1]}:#{x[0]}"
  end

  def self.split_ext(file_name)
    file_name.split('.').last
  end

  def base_name
    return false unless title
    title.split('.').first
  end
  def date_prefix
    return false unless base_name
    split = base_name.split('_').first
    return false unless split && split =~ /\d\d\d\d-\d\d-\d\d/
    split
  end
  def date_serial_number
    return false unless base_name
    split = base_name.split('_').second
    return false unless split && split =~ /\d\d\d/
    split
  end
  def title_string
    return false unless base_name
    split = base_name.split('_').third
    return false unless split && split.length > 1
    split
  end
  def uses_conventional_title?
    date_prefix && date_serial_number && title_string
  end

  def serial_number
    (piece.videos.index(self)+1).to_s
  end
  def comes_before(video2)
    return false unless date_prefix && video2.date_prefix
    return false if video2.date_prefix.to_i < date_prefix.to_i
    return true if video2.date_prefix.to_i > date_prefix.to_i
    return false unless date_serial_number && video2.date_serial_number
    return false if video2.date_serial_number.to_i <= date_serial_number.to_i
    true
  end

  def self.parse_date_from_title(title)
      base_title = title.split('.').first
      date_part = base_title.split('_').first
      if date_part =~ /\d\d\d\d-\d\d-\d\d/ 
        date_part.to_date
      else
        nil
      end
  end
  def times
    tims = events.map{|x| [x.video_start_time,x.duration,x.id]}
    tims.sort_by{|x| x[0]}
    times = tims.to_json
  end
  def event_at(time)
    events.select{|x| x.happened_at - recorded_at < time}.last
  end
  def set_new_title(piece)
    
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


  def guess_piece_title
    name = title.split('.')
    name.pop
    name      = name.join('.')
    last_part = name.split('_').last

  end
  def false_string
    '<span style = "color:#a00">F</span>'
  end
  def true_string
    '<span style = "color:#0a0">T</span>'
  end
  def local_show
    fn_local ? true_string : false_string
  end
  def S3_show
    fn_s3 ? true_string : false_string
  end
  def self.list_in_s3
    if @sl == nil
      begin
        logger.warn{'********** looking in s3'}
        @sl = S3Config.connect_and_get_list
      rescue
        @sl = false
      end
    end
    @sl
  end
  def confirm_presence(locats = ['uncompressed'])
    result = {:message => '',:error => '' }
    if locats.include? 'uncompressed'
      if local_present?
        self.fn_local = '.mp4'
      else
        self.fn_local = nil
      end
    end
    if locats.include? 'archive'
      case archive_present?
      when 'true'
        self.fn_arch = '.mp4'
      when 'false'
        self.fn_arch = nil
      else
        result[:error] << 'No Archive Access'
      end
    end
    if locats.include? 's3'
      case s3_present?
      when 'true'
        self.fn_s3 = '.mp4'
      when 'false'
        self.fn_s3 = nil
      else
        result[:error] << ' No S3 Access'
      end
    end
     save
     result
  end
  def viewable?
    is_uploaded
  end
  def meta_data_present
    meta_data ? 'True' : 'False'
  end
  def self.update_heroku
    if SetupConfiguration.app_is_local?
      Dir.chdir(Rails.root)
      system "heroku db:push --app piecemaker-#{SetupConfiguration.s3_base_folder} --confirm piecemaker-#{SetupConfiguration.s3_base_folder}"
    end
  end
  
  
  def self.fix_titles(from, to)
    vids = all.select{|x| x.title =~ /#{Regexp.escape(from)}/}
    puts "fixing #{vids.length} files"
    vids.each do |vid| 
      new_title = vid.title.gsub(from,to)
      puts "renaming #{vid.title}"
      rename_file_locations(vid.title,new_title)
      rename_s3(vid.title,new_title)
    end
  end


  def destroy_all
    delete_s3
    destroy
  end
end


# == Schema Information
#
# Table name: videos
#
#  id          :integer(4)      not null, primary key
#  title       :string(255)
#  recorded_at :datetime
#  duration    :integer(4)
#  fn_local    :string(255)
#  fn_arch     :string(255)
#  fn_s3       :string(255)
#  vid_type    :string(255)     default("rehearsal")
#  rating      :integer(4)      default(0)
#  meta_data   :text
#  created_at  :datetime
#  updated_at  :datetime
#

