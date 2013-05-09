# class Video < ActiveRecord::Base
# end
class Video

  MOVIE_EXTENSIONS = %w[mov mp4 m4v flv]


  require 's3_paths'
  include S3Paths

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
    Rails.root.to_s + '/public/video/backup'
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
  def old_date_format
    split = base_name.split('_').first
    return false unless split && split =~ /\d\d\d\d\d\d\d\d/
    split
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





  def self.prepare_recording(player_name = Piecemaker.config.quicktime_player)
    prep = <<ENDOT

tell application "#{player_name}"
close every document
new movie recording
end tell
ENDOT
    system "osascript -e '#{prep}'"
  end


  def self.start_recording(player_name = Piecemaker.config.quicktime_player)
    start = <<ENDOT
tell application "#{player_name}"
start every document
activate
end tell
ENDOT
    system "osascript -e '#{start}'"
  end


  def self.stop_recording(new_file_name = nil,player_name = Piecemaker.config.quicktime_player)
    # i have to do this becaus3 of differences between qt player versions

    divider = player_name == 'QuickTime Player 7' ? '/' : ':'
    qt_path_command = player_name == 'QuickTime Player 7' ? 'path' : 'file'
stop = <<ENDOT
tell application "#{player_name}"
try
  stop every document
  set y to #{qt_path_command} of first document
  y
on error
  return "error"
end try
end tell
ENDOT
    orig_file_path = `osascript -e '#{stop}'`.chomp
    return 'error' if orig_file_path == 'error'
    file_path = orig_file_path.gsub(' ', '\ ').split(divider)
    file_path.slice!(0) #take off first part of path, I will put in a / later
    qt_file_name = file_path.pop #original name given by quicktime
    file_path = '/' + file_path.join('/')
    full_qt_file_name = file_path + '/' + qt_file_name
    new_file_name ||= qt_file_name
    new_name = Video.uncompressed_dir + '/' + new_file_name
    backup_name = Video.backup_dir + '/' + new_file_name
    if true# system "which qt-fast"
      system "mv #{full_qt_file_name} #{backup_name}"
      system "/usr/local/bin/qt-fast #{backup_name} #{new_name}" # move output to temp and rename
      x = 'fast'
    else
      #system "cp #{full_qt_file_name} #{backup_name}"
      system "mv #{full_qt_file_name} #{new_name}" # move output to temp and rename
      x = 'not fast'
    end
    qt_file_name
end
  def self.get_files_from_directory(dir_name)
    Dir.chdir(dir_name)
    Dir.glob('*').select{|x| ['mp4','mov'].include?(x.split('.').last)}
  end
  def self.uncompressed_files
    Event.where("state = 'uncompressed'")
  end


  def self.compressable_files(days_back = nil)
    days_back ||= Video.days_back_to_compress
    full = Video.uncompressed_dir
    comp = Video.compressed_dir
    cf = Video.get_files_from_directory(full) - Video.get_files_from_directory(comp)
    #cf.reject!{|x| video_uploaded(x)}
    cf = cf.select{|x| Video.parse_date_from_title(x) && (Video.parse_date_from_title(x) >= Date.today - days_back.days)}
  end
  def self.compressable_files(days_back = nil)
    Video.uncompressed_files.map{|x| x.title}
  end
  def self.compress_compressable(days_back = nil)
    videos = Video.uncompressed_files
    puts "#{videos.length.to_s} files to compress."
    videos.each do |video|
      x = video.title
      puts "Compressing #{x}"
      Video.compress_file(Video.uncompressed_dir + '/' + x, Video.compressed_dir + '/' + x)
      video.state = 'compressed'
      video.save

    end
  end
  def self.compress_file(from,to,force = false)
    puts "******** Starting to compress #{from}."
    if File.exists?(from)
      if File.exists?(to) && !force
        puts "******** File #{to} exists already. Skipping"
      else
        puts compression_command(from,to)
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
      "/Users/davidkern/bin/HandBrakeCLI --encoder x264 -q 22 --maxWidth 480 --optimize -i #{from} -o #{to}"
    end
  end

  # def self.uploadable_files
  #   @uploadable ||= uploadable_file_listing#[0..0]
  # end
  def self.uploadable_files_get
    uploadable = []
    files = Event.where("state = 'compressed'")
    files.each do |file|
      if File.exist?(Video.compressed_dir + '/' + file.title)
        uploadable << file
      else
        puts "I couldn't find #{Video.compressed_dir + '/' + file.title}"
      end
    end
    uploadable
  end
  def self.uploadable_files
    @uploadable ||= Video.uploadable_files_get
  end
  def self.uploadable_file_listing
    puts "Fetching S3 List"
    bucket_list = S3Config.connect_and_get_list.select{|x| y = x.split('/'); y.first == SetupConfiguration.s3_base_folder && y[1] == 'video'}.map{|x| x.split('/').last}
    compressed_list = get_files_from_directory(Video.compressed_dir).select{|x| !bucket_list.include?(x)}
  end
  def self.time_estimate_string(size)
    "#{Video.calculate_time(size)} ETA: #{(Time.now + seconds_to_upload(size)).strftime('%H:%M:%S')}"
  end
  def self.calculate_time(size)
    upload_time = Video.seconds_to_upload(size).floor.divmod(60)
    "#{upload_time[0].to_s}m #{upload_time[1].to_s}s"
  end
  def self.seconds_to_upload(size)
    (size.to_f / Video.upload_speed).to_i
  end
  def self.upload_speed
    94000
  end
  def self.total_size
      total_size = uploadable_files.inject(0){|sum, x| sum + File.size(Video.compressed_dir + '/' + x.title)}
      puts "#{uploadable_files.length} videos to upload."
      puts "This will take at least #{Video.time_estimate_string(total_size)}"
      puts "#{total_size} bytes."
  end
  def self.list_uploadable
    if uploadable_files.any?
     Video.total_size
      uploadable_files.each do |one_file|
        puts one_file.title
      end
    else
      puts "Nothing to do."
    end
  end

  def self.upload_uploadable
    if uploadable_files.any?
      start_time = Time.now
      Video.total_size

      uploadable_files.each do |video|
        filename = video.title
        full_file_path = Video.compressed_dir + '/' + filename
        full_s3_path = SetupConfiguration.s3_base_folder + '/video/' + filename
        if file = File.open(full_file_path)
          size = File.size(full_file_path)
          puts "#{Time.now.strftime('%H:%M:%S')} Uploading #{filename}  #{time_estimate_string(size)}"
          begin
            AWS::S3::S3Object.store(full_s3_path, file, S3Config.bucket, :access => 'public_read')
              video.state = 'uploaded'
              video.save
              puts "Updated database for #{filename}"
          rescue Exception => e
            puts "#{Time.now.strftime('%H:%M:%S')} AWS S#3 Error: #{e.inspect}"
            puts e.backtrace.inspect
            puts full_file_path
          end
        else
          puts "Problem finding #{full_file_path}"
        end
      end
      finish_time = Time.now
      tot = finish_time - start_time
      minu = tot.floor.divmod(60)
      puts "Finished #{finish_time.strftime("%H:%M:%S")}"
      puts "Total time: #{minu[0].to_s}m #{minu[1].to_s}s"
    else
      puts "Nothing to Upload"
    end
  end

  #def rename_quicktime_and_queue_processing(qt_title)
    #qtplayer_output = Video.uncompressed_dir + '/' + qt_title
    #system "mv #{qtplayer_output} #{full_uncompressed_path}" # move output to temp and rename
    #Video.send_later(:do_moov_atom,id,full_uncompressed_path,full_temp_path)
    ##Video.send_later(:backup_and_compress, id, full_backup_path, full_compressed_path,full_uncompressed_path,full_archive_path,full_temp_path)
  #end
end
