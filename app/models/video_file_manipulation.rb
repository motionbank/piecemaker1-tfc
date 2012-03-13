module FileManipulation
  # these become video class methods

  def fix_moov_atom(from,to)
    command = RAILS_ROOT + "/vendor/bin/#{Configuration.arch_type}/qt-fast #{from} #{to}"
    if `#{command}` == "last atom in file was not a moov atom\n"
      `mv -f #{from} #{to}`
    end
    puts "******** fixed moov atom of #{from}"
  end
  def copy_file(from,to)
    #command = "cp #{from} #{to}"
    mess = system "cp #{from} #{to}"   
    if mess
      puts "******** copied from #{from} to #{to}"
    else
      puts "******** failed copy from #{from} to #{to}"
    end
    mess
  end
  def move_file(from,to)
    #command = "mv #{from} #{to}"
    mess = system "mv -f #{from} #{to}"
    if mess
     puts "******** moved from #{from} to #{to}"
   else
     puts "******** failed move from #{from} to #{to}"
   end
    mess
  end

  def list_in_folder(folder,truncate_extension = true)
      begin
        puts "********** looking in #{folder}"
        Dir.chdir(folder)
        al = Dir.glob('*')
        fl = al.select{|x| Video::MOVIE_EXTENSIONS.include?(x.split('.').last)}.sort
        fl = fl.map{|x| x.split('.').first} if truncate_extension
      rescue
        false
      end
      fl
  end

  def list_in_archive(truncate_extension = true)
    if @arch_list == nil
      @arch_list = list_in_folder(archive_path,truncate_extension)
    end
    @arch_list
  end
  def archive_online?
    !!Dir.chdir(archive_path)
  end
  def get_missing_from_folder(db_list,folder_list)
    db_list.select{|x| x.fn_arch && !folder_list.include?(x.title)}
  end
  def get_missing_from_db(folder_list,db_title_list)
    folder_list.select{|x| !db_title_list.include?(x)}
  end

  def get_annotations_from_file(path_to_file)
    com  = '"' + RAILS_ROOT + '/vendor/bin/'+ Configuration.arch_type + '/qt_info" ' + path_to_file
    data = `#{com}`
    if data
      sp   = data.split('+').map{|z| z.strip}
      spp  = sp.map{|c| c.split(' : ')}
      acc  = {}
      spp.each do |inf|
        acc  [inf[0]] = inf[1]
      end
      acc
    else
      nil
    end
  end

  def compress_file(from,to)#
    puts "******** Starting to compress #{from}."
    if File.exists?(from)
      if File.exists?(to)
        puts "******** File #{to} exists already. Skipping"
      else
        system compression_command(from,to)
        puts "******** Finished compressing #{to}."
      end
    else
      puts "******** File #{from} doesn't exist. Can't compress"
    end
    
  end

  def delayed_compress_videos(vid_ids)
    send_later(:compress_videos,vid_ids)
  end
  def compress_videos(vid_ids)
    videos = find(vid_ids)
    videos.each do |video|
      compress_file(full_uncompressed_path,full_compressed_path)
    end
  end
  
  def upload_to_s3(local_path,s3_path,force = false)
      if file = File.open(local_path)
        bucket = S3Config.bucket
        S3Config.connect_to_s3
        if force || !AWS::S3::S3Object.exists?(s3_path,bucket)
          puts "#{Time.now.to_s} connected to s3 storing #{local_path}"
          AWS::S3::S3Object.store(s3_path, file, bucket, :access => 'public_read')
          puts "#{s3_path} stored on s3"
        else
          puts "Warning #{s3_path} exists already use force = true to overwrite"
        end
        true
      else
        puts "Warning #{local_path} doesn't exist"
        false
      end
  end
  
  def rename_s3(from,to)
    prefix = 'tfc/video/'
    from = prefix + from + '.mp4'
    to = prefix + to + '.mp4'
    bucket = S3Config.bucket
    S3Config.connect_to_s3
    puts "********** connected to s3 copying #{from}"
    if AWS::S3::S3Object.exists?(from,bucket)
      puts "doing it"
      AWS::S3::S3Object.copy(from, to, bucket)
    end
  end
  
  def rename_file_locations(from,to)
    from = from + '.mp4'
    to = to + '.mp4'
    [Video.compressed_dir, Video.archive_dir, Video.uncompressed_dir].each do |location|
      if File.exist?(location + '/' + from)
        move_file(location + '/' + from,location + '/' + to)
      end
    end
  end
  
  def upload_compressed_folder(force_upload)
    #should get contents of compressed folder then intellegently decide which video it is and upload it to s3 giving it the correct path. Returns a FORMATTED list
    videos = all.reject{|x| !x.title}.reject{|x| x.fn_s3}
    video_title_list = videos.map{|x| x.title} #titles without extension
    list_of_uploading_videos = []
    to_do = list_in_folder(compressed_dir).select{|x| video_title_list.include?(x)}
    videos_to_do = to_do.map{|x| videos.find{|y| y.title == x}}
    vid_ids = videos_to_do.map{|z| z.id}
    videos_to_do.each do |video|
      list_of_uploading_videos << "local: #{video.full_uncompressed_path}<br />s3: #{video.s3_path}<br />id: #{video.id}"
    end
    send_later(:upload_videos, vid_ids) if force_upload
    list_of_uploading_videos
  end
  
  def upload_and_update(vid_id,local_path,s3_path)
    upload_to_s3(local_path,s3_path)
    vid = find(vid_id)
    vid.mark_in('s3')
  end
  def upload_videos(vid_ids)
    videos = find(vid_ids)
    videos.each do |video|
      if upload_to_s3(video.full_compressed_path,video.s3_path)
        video.mark_in('s3')
        system "curl http://piecemaker.org/video/mark_as_uploaded/#{video.id.to_s}"
      end
    end
  end
  def delayed_upload_videos(vid_ids)
    send_later(:upload_videos,vid_ids)
  end

  def backup_and_compress(vid, backup_path, compressed_path, uncompressed_path, archive_path,temp_path)#
    #first backup
    copy_file(uncompressed_path,backup_path)
    #make fix the moov atom
    fix_moov_atom(uncompressed_path,temp_path)
    move_file(temp_path,uncompressed_path)
    #then make archive copy
    if copy_file(uncompressed_path,archive_path)
      video = find(vid)
      video.mark_in('archive')
      video.save
    end
    #then compress
    compress_file(uncompressed_path,compressed_path)
  end

  def do_moov_atom(id,uncompressed,temp)
    fix_moov_atom(uncompressed,temp)
    move_file(temp,uncompressed)
  end

end













module FileInstanceMethods
  
  def full_compressed_path
    Video.compressed_dir + '/' + title + '.mp4'
  end

  def full_uncompressed_path
    Video.uncompressed_dir + '/'+ title + '.mp4'
  end

  def full_temp_path
    Video.temp_dir + '/'+ title + '.mp4'
  end
  
  def full_backup_path
    Video.backup_dir + '/'+ title + '.mp4'
  end
  
  def full_archive_path
    Video.archive_path + '/' + title + '.mp4'
  end

  def full_archive_alias
    Video.archive_alias + '/' + Video.archive_dir + '/' + title + fn_arch
  end
  
  def full_local_alias
    Video.local_alias + '/'+ title + '.mp4'
  end
  
  
  def upload_to_s3(force = false)#############
      if Video.upload_to_s3(full_compressed_path,s3_path,force)
        mark_in('s3')
      end
  end
  def rename_quicktime_and_queue_processing(qt_title)
    qtplayer_output = Video.uncompressed_dir + '/' + qt_title
    #hello
    system "mv #{qtplayer_output} #{full_uncompressed_path}" # move output to temp and rename
    Video.send_later(:do_moov_atom,id,full_uncompressed_path,full_temp_path)
    #Video.send_later(:backup_and_compress, id, full_backup_path, full_compressed_path,full_uncompressed_path,full_archive_path,full_temp_path)
  end

  def delayed_archive
    send_later(:archive)
  end
  def archive
    if Video.move_file(full_uncompressed_path, full_archive_path)
      mark_in('archive')
    end
  end
  def delayed_dearchive
    send_later(:dearchive)
  end
  def dearchive
    if Video.move_file(full_archive_path, full_uncompressed_path)
      mark_in('local')
    end
  end
  def delayed_compress_and_upload
    send_later(:compress_and_upload)
  end
  def compress_and_upload
    Video.compress_file(full_uncompressed_path,full_compressed_path)
    if Video.upload_to_s3(full_uncompressed_path,s3_path)
      mark_in('s3')
    end
  end
  def delayed_dearchive_compress_and_upload
    send_later(:dearchive_compress_and_upload)
  end

  def dearchive_compress_and_upload
    #move from archive
    if Video.copy_file(full_archive_path,full_uncompressed_path)
      mark_in('local')
    end
    Video.compress_file(full_uncompressed_path,full_compressed_path)
    if Video.upload_to_s3(full_uncompressed_path,s3_path)
      mark_in('s3')
    end
  end
  def get_annotations
    text = ''
    meta_data = Video.get_annotations_from_file(full_uncompressed_path)
    if meta_data
      text << "duration:#{meta_data['movie duration']}\n"
      text << "dimensions:#{meta_data['width/height/depth']}"
      self.meta_data = text
      self.save
    end
  end
  def destroy_all
    leftovers = Video.file_locations - delete_files
    Message.message_to(1,0,"couldn't delete title: #{title} -- formats: #{leftovers.join(', ')}")
    destroy
  end
  def delete_files
    # tries to delete the various files laying around and returns an array of what it managed to delete
    string = []
    Video.file_locations.each do |cmd|
      string << cmd if send("delete_#{cmd}")
    end
    string
  end
  def delete_arch
    if fn_arch && File.exists?(full_archive_path)
      result = `rm #{full_archive_path}`
    else
      false
    end
  end
  
  def delete_backup
    if fn_arch && File.exists?(full_backup_path)
      result = `rm #{full_backup_path}`
    else
      false
    end
  end
  
  def delete_local
    if fn_local && File.exists?(full_uncompressed_path)
      result = `rm #{full_uncompressed_path}`
    else
      true
    end
  end
  def delete_compressed
    if fn_local && File.exists?(full_compressed_path)
      result = `rm #{full_compressed_path}`
    else
      true
    end
  end

  def local_present?
    Video.list_in_folder(Video.uncompressed_dir,true).include?(title)
  end
  def archive_present?
    archive_list = Video.list_in_archive(true)
    if archive_list
      archive_list.include?(title) ? 'true' : 'false'
    else
      "No Archive Access"
    end
  end
  def s3_present?
    s3_list = Video.list_in_s3
    if s3_list
      s3_list.include?(s3_path) ? 'true' : 'false'
    else
      "No S3 Access"
    end
  end

end