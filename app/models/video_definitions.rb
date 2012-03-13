module VideoDefinitions

  def directories
    %w[local compressed temp backup uncompressed]
  end

  def file_locations
    ['arch','compressed','local','s3']
  end
  
  def compressed_dir
    Configuration.compressed_dir
  end
  
  def uncompressed_dir
    Configuration.uncompressed_dir
  end
  
  def temp_dir
    Configuration.temp_dir
  end
  
  def backup_dir
    Configuration.backup_dir
  end
  
  def archive_base_path
    '/Volumes/VIDEOARCHIV'
  end
  
  def archive_path
    archive_base_path + '/'+ archive_dir
  end
  
  def archive_dir
    'VIDEOARCHIVE_MASTER_LoRes'
  end
  
  def archive_alias
    '/archiv' # an apache alias to the archive video folder. Check your httpd.conf
  end
  
  def local_alias
    '/video/full' # an apache alias to the local video folder. Check your httpd.conf
  end
  
  def default_file_extension
    '.mp4'
  end

  def archive_dir_online?
    begin
      Dir.chdir("#{archive_base_path}/#{archive_dir}")
      true
    rescue
      false
    end
  end
  

  def compression_command(from,to,type = 'handbrake')
    if type == 'ffmpeg'
      RAILS_ROOT + "/vendor/bin/#{Configuration.arch_type}/HEAD/bin/ffmpeg -i #{from} -acodec libfaac -ab 96k -vcodec libx264 -vpre medium -crf 20 -threads 0 -y -s 480x360 #{to}"
    else
      RAILS_ROOT + "/vendor/bin/#{Configuration.arch_type}/HandBrakeCLI --encoder x264 -q 22 --maxWidth 480 --optimize -i #{from} -o #{to}"
    end
  end
  
  def create_snapshot(infile,time,outfile) #not finished
    command = "ffmpeg -i #{infile}  -r 1 -ss #{time} -t 1 #{outfile}"
  end

end
