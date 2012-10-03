namespace :piecemaker do
  #require Rails.root.to_s + '/config/environment'
  def video_base_folder
    'video'
  end
  def days_back_to_compress
    40
  end
  def upload_speed
    94000
  end
  def uncompressed_folder
    Video.uncompressed_dir
  end
  def compressed_folder
    Video.compressed_dir
  end
  def archive_folder
    '/Volumes/VIDEOARCHIV/VIDEOARCHIVE_MASTER_LoRes'
  end
  def get_files_from_directory(dir_name)
    Dir.chdir(dir_name)
    Dir.glob('*').select{|x| ['mp4','mov'].include?(x.split('.').last)}
  end
  def video_uploaded(filename)
    vid = Video.find_by_title(filename.gsub('.mp4',''))
    if vid
      puts vid.fn_s3
      vid.fn_s3 == '.mp4'
    else
      false
    end
  end
  def compressable_files(full = nil, comp = nil)
    full ||= uncompressed_folder
    comp ||= compressed_folder
    @full_files ||= get_files_from_directory(full)
    @compressed_files ||= get_files_from_directory(comp)
    cf = @full_files - @compressed_files
    #cf.reject!{|x| video_uploaded(x)}
    @cf ||= cf.select{|x| Video.parse_date_from_title(x) >= Date.today - days_back_to_compress.days}
  end
  def archivable_files(full = nil, arch = nil)
    full ||= uncompressed_folder
    arch ||= archive_folder
    @full_files ||= get_files_from_directory(full)
    @archived_files ||= get_files_from_directory(arch)
    @af = @full_files - @archived_files
  end
  def uploadable_files
    @uploadable ||= uploadable_file_listing#[0..0]
  end
  def uploadable_file_listing
    puts "Fetching S3 List"
    bucket_list = S3Config.connect_and_get_list.select{|x| y = x.split('/'); y.first == Configuration.s3_base_folder && y[1] == 'video'}.map{|x| x.split('/').last}
    compressed_list = get_files_from_directory(compressed_folder).select{|x| !bucket_list.include?(x)}
  end
  def calculate_time(size)
    upload_time = seconds_to_upload(size).floor.divmod(60)
    "#{upload_time[0].to_s}m #{upload_time[1].to_s}s"
  end
  def seconds_to_upload(size)
    (size.to_f / upload_speed).to_i
  end
  def time_estimate_string(size)
    "#{calculate_time(size)} ETA: #{(Time.now + seconds_to_upload(size)).strftime('%H:%M:%S')}"
  end
  desc 'Moving File'
  task :move_it do
    puts 'moving'
  end
  
  desc 'Listing Archiveable Files'
  task :list_archivable do
    puts "List of non-archived files."
    archivable_files.each do |x|
      puts x
    end
    puts "#{archivable_files.length.to_s} files."
  end
  
  desc 'Archiving Archivable Files'
  task :archive_archivable do
    puts "#{archivable_files.length.to_s} files to archive."
    archivable_files.each do |x|
      puts 'Copying ' + x
      Video.copy_file(uncompressed_folder + '/' + x,archive_folder + '/' + x)
    end
  end
  
  
  desc 'Listing Compressable Files'
  task :list_compressable do
    puts "List of non-compressed files."
    compressable_files.each do |x|
      puts x
    end 
  end
  desc 'Compressing Compressable Videos'
  task :compress_compressable do
    puts "#{compressable_files.length.to_s} files to compress."
    compressable_files.each do |x|
      puts "Compressing #{x}"
      Video.compress_file(uncompressed_folder + '/' + x, compressed_folder + '/' + x) 
    end
  end
  
  desc 'List Uploadable'
  task :list_uploadable do
    if uploadable_files.any?
      total_size = uploadable_files.inject(0){|sum, x| sum + File.size(compressed_folder + '/' + x)}
      puts "#{uploadable_files.length} videos to upload."
      puts "This will take at least #{time_estimate_string(total_size)}"
      puts "#{total_size} bytes."
      uploadable_files.each do |one_file|
        puts one_file
      end
    else
      puts "Nothing to do."
    end
  end
  desc 'Upload files from compressed folder to S3'
  task :upload_uploadable do
    if uploadable_files.any?
      total_size = uploadable_files.inject(0){|sum, x| sum + File.size(compressed_folder + '/' + x)}
      start_time = Time.now
      puts "Uploading #{uploadable_files.length.to_s} files, #{total_size.to_s} bytes."
      puts "This will take at least #{time_estimate_string(total_size)}"
      puts "Starting #{start_time.strftime("%H:%M:%S")}" 
      uploadable_files.each do |filename|
        full_file_path = compressed_folder + '/' + filename
        full_s3_path = Configuration.s3_base_folder + '/video/' + filename
        if file = File.open(full_file_path)
          size = File.size(full_file_path)
          puts "#{Time.now.strftime('%H:%M:%S')} Uploading #{filename}  #{time_estimate_string(size)}"
          begin
            AWS::S3::S3Object.store(full_s3_path, file, S3Config.bucket, :access => 'public_read')
            video = Video.find_by_title(filename.gsub('.mp4',''))
            if video
              video.fn_s3 = '.mp4'
              video.save
              puts "Updated database for #{filename}"
            end
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
end
=begin
  TODO startup_tasks: create folders, create s3 bucket, seed db
  everyday_tasks: compress compressable, upload compressed
=end
