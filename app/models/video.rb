class Video < ActiveRecord::Base

  MOVIE_EXTENSIONS = %w[mov mp4 m4v flv]


  require 's3_paths'
  include S3Paths


  #belongs_to :event
  belongs_to :piece

  #has_many :video_recordings
  has_many :events,:dependent => :nullify, :order => :happened_at,:conditions => "state = 'normal'"
  scope :active, :conditions => "state = 'normal'"

  acts_as_tenant(:account)

  after_save :rename_files_on_title_change###################

## this is to help migrations
 def self.create_events
    Video.all.each do |video|
      ee = Event.create(
        :title => video.title,
        :piece_id => video.piece_id,
        :rating => video.rating,
        :state => video.is_uploaded ? 'uploaded' : 'normal',
        :happened_at => video.recorded_at,
        :dur => video.duration,
        :created_at => video.created_at,
        :updated_at => video.updated_at,
        :account_id => video.account_id,
        :description => video.meta_data,
        :event_type => 'video'

        )
      video.events.each do |ev|
        ev.video_id = ee.id
        ev.save
      end
    end
  end
  def self.add_suffixes
    all.each do |x|
      if x.title && x.title.split('.') != 'mp4'
        x.title = x.title + '.mp4'
        x.save
      end
    end
  end
  def self.fix_recordings
    all.each do |vid|
      if vid.video_recordings.length == 1
        vid.piece_id = vid.video_recordings.first.piece_id
        vid.save
        vid.video_recordings.first.destroy
      end
    end
  end
  def self.fix_uploaded
    all.each do |vid|
      vid.is_uploaded = true if vid.fn_s3 == '.mp4'
      vid.save
    end
  end


## end of migration stuff

  def self.days_back_to_compress
    40
  end

  def self.uncompressed_dir
    Rails.root.to_s + '/public/video/full'
  end
  def self.compressed_dir
    Rails.root.to_s + '/public/video/compressed'
  end
  def self.backup_dir
    Rails.root.to_s + '/public/video/back'
  end
  def full_local_alias
    '/video/full/' + title
  end

  def online?
    file_path = Rails.root.to_s + '/public' + full_local_alias
    File.exists? file_path
  end
  def rename_files_on_title_change###################
    if self.title_changed?
      logger.info '******* title changed moving files'
    end
  end
  def update_from_params(params)
    self.title = params[:title]
    self.is_uploaded = true
    save
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
    elsif date_part =~ /\d\d\d\d\d\d\d\d/ 
      year = date_part[0..3]
      month = date_part[4..5]
      day = date_part[6..7]
      mdy = day+'/'+month+'/'+year
      mdy.to_date
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

  def viewable?
    true#is_uploaded
  end
  def meta_data_present
    meta_data ? 'True' : 'False'
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


  def self.prepare_recording
    prep = <<ENDOT
do shell script "defaults write com.apple.QuickTimePlayerX NSNavLastRootDirectory ~/Desktop"

tell application "QuickTime Player"
close every document
new movie recording
end tell
ENDOT
    system "osascript -e '#{prep}'"
  end


  def self.start_recording
    start = <<ENDOT
tell application "QuickTime Player"
start every document
activate
end tell
ENDOT
    system "osascript -e '#{start}'"
  end


  def self.stop_recording(new_file_name = nil)
stop = <<ENDOT
tell application "QuickTime Player"
try
  stop every document
  set y to file of first document
  y
on error
  return "error"
end try
end tell
ENDOT
    orig_file_path = `osascript -e '#{stop}'`.chomp
    if orig_file_path != 'error'
      file_path = orig_file_path.gsub(' ', '\ ').split(':')
      file_path.slice!(0) #take off first part of path, I will put in a / later
      qt_file_name = file_path.pop #original name given by quicktime
      file_path = '/' + file_path.join('/')
      full_qt_file_name = file_path + '/' + qt_file_name
      new_file_name ||= qt_file_name
      new_name = Video.uncompressed_dir + '/' + new_file_name
      backup_name = Video.backup_dir + new_file_name
      if false#true# system "which qt-fast"
        system "/usr/local/bin/qt-fast #{full_qt_file_name} #{new_name}" # move output to temp and rename
        system "mv #{full_qt_file_name} #{backup_name}"
      else
        #system "cp #{full_qt_file_name} #{backup_name}"
        system "mv #{full_qt_file_name} #{new_name}" # move output to temp and rename
      end
      qt_file_name
    else
      'error'
    end
end
  def self.get_files_from_directory(dir_name)
    Dir.chdir(dir_name)
    Dir.glob('*').select{|x| ['mp4','mov'].include?(x.split('.').last)}
  end

 def self.compressable_files(days_back = nil)
    days_back ||= Video.days_back_to_compress
    full = Video.uncompressed_dir
    comp = Video.compressed_dir
    cf = Video.get_files_from_directory(full) - Video.get_files_from_directory(comp)
    #cf.reject!{|x| video_uploaded(x)}
    cf = cf.select{|x| Video.parse_date_from_title(x) && (Video.parse_date_from_title(x) >= Date.today - days_back.days)}
  end
  def self.compress_compressable(days_back = nil)
    files = Video.compressable_files(days_back)
    puts "#{files.length.to_s} files to compress."
    files.each do |x|
      puts "Compressing #{x}"
      Video.compress_file(Video.uncompressed_dir + '/' + x, Video.compressed_dir + '/' + x) 
    end
  end
  def self.compress_file(from,to,force = false)
    puts "******** Starting to compress #{from}."
    if File.exists?(from)
      if File.exists?(to) && !force
        puts "******** File #{to} exists already. Skipping"
      else
        system compression_command(from,to)
        puts "******** Finished compressing #{to}."
      end
    else
      puts "******** File #{from} doesn't exist. Can't compress"
    end
  end

  def self.compression_command(from,to,type = 'handbrake')
    if type == 'ffmpeg'
      "/vendor/bin/#{Configuration.arch_type}/HEAD/bin/ffmpeg -i #{from} -acodec libfaac -ab 96k -vcodec libx264 -vpre medium -crf 20 -threads 0 -y -s 480x360 #{to}"
    else
      "/usr/local/bin/HandBrakeCLI --encoder x264 -q 22 --maxWidth 480 --optimize -i #{from} -o #{to}"
    end
  end

  #def rename_quicktime_and_queue_processing(qt_title)
    #qtplayer_output = Video.uncompressed_dir + '/' + qt_title
    #system "mv #{qtplayer_output} #{full_uncompressed_path}" # move output to temp and rename
    #Video.send_later(:do_moov_atom,id,full_uncompressed_path,full_temp_path)
    ##Video.send_later(:backup_and_compress, id, full_backup_path, full_compressed_path,full_uncompressed_path,full_archive_path,full_temp_path)
  #end





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

