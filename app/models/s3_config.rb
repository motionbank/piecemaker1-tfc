class S3Config

  def self.access_key_id
    ENV['S3_ACCESS_KEY_ID']
  end
  def self.secret_access_key
    ENV['S3_SECRET_ACCESS_KEY']
  end
  def self.bucket
    'piecemaker1'
  end
  def self.max_file_size
    ENV['S3_SWF_MAX_FILE_SIZE'] || 535544320
  end
  def self.acl
    ENV['S3_SWF_UPLOAD_ACL'] || 'public-read'
  end
  def self.cloudfront_address
    's117io70xp4y5p.cloudfront.net/cfx/st'
  end
  def self.upload_speed
    94000
  end

  def self.time_estimate_string(size)
    "#{calculate_time(size)} ETA: #{(Time.now + seconds_to_upload(size)).strftime('%H:%M:%S')}"
  end

  def self.calculate_time(size)
    upload_time = seconds_to_upload(size).floor.divmod(60)
    "#{upload_time[0].to_s}m #{upload_time[1].to_s}s"
  end

  def self.seconds_to_upload(size)
    (size.to_f / upload_speed).to_i
  end

  def self.upload_video_file(video)
    S3Config.connect_to_s3
    filename = video.title
    from = Video.compressed_dir + '/' + filename
    to = SetupConfiguration.s3_base_folder + '/video/' + filename
    if file = File.open(from)
      size = File.size(from)
      puts "#{Time.now.strftime('%H:%M:%S')} Uploading #{filename}  #{S3Config.time_estimate_string(size)}"
      begin
        AWS::S3::S3Object.store(to, file, S3Config.bucket, :access => 'public_read')
          puts "Uploaded #{filename}"
          true
      rescue Exception => e
        puts "#{Time.now.strftime('%H:%M:%S')} AWS S#3 Error: #{e.inspect}"
        puts e.backtrace.inspect
        puts from
      end
    else
      puts "Problem finding #{from}"
    end
  end

  def self.connect_to_s3
    begin
      result = AWS::S3::Base.establish_connection!(
      :access_key_id     => S3Config.access_key_id,
      :secret_access_key => S3Config.secret_access_key
        )
      puts('****** connected to s3')
    rescue
      puts('****** failed to connected to s3')
      return false
    end
  end

  def self.rename(from,to)
    S3Config.connect_to_s3
    begin
      obj = AWS::S3::S3Object.find(from,S3Config.bucket)
      puts "***** renaming #{obj.key} to #{to}"
      obj.rename(to,:access => 'public_read')
    rescue
      puts "***** can't find #{obj.key}"
    end
    puts "***** done"
  end

  def self.connect_and_get_bucket
    begin
      S3Config.connect_to_s3
      connection_bucket = AWS::S3::Bucket.find(S3Config.bucket)
      puts("****** found bucket '#{S3Config.bucket}' on s3")
      connection_bucket
    rescue
      puts("****** failed to find bucket '#{S3Config.bucket}' on s3")
      return false
    end
  end

  def self.connect_and_get_list(group_string = nil)
      @llst = S3Config.connect_and_get_objects(group_string)
      if @llst
        @llst = @llst.map{|x| x.key}
      end
        @llst
  end

  def self.connect_and_get_objects(group_string = nil)
    bucket = S3Config.connect_and_get_bucket
    if bucket
      acc = []
      acc += bucket.objects
      marker = true
      while marker
      new_stuff = bucket.objects(:marker => acc.last.key)
        if new_stuff.length > 0
          acc += new_stuff
        else
          marker = false
        end
      end
      if group_string
        acc = acc.select{|x| x.key.split('/')[0] == group_string}
      end
      acc
    else
      false
    end
  end
  def self.find_keys_with_string(search_string)
    all_objects = self.connect_and_get_objects
    all_objects.select{|x| /#{Regexp.escape(search_string)}/ =~ x.key}
  end
  def self.rename_all(search,replace)
    self.find_keys_with_string(search).each do |obj|
      from = obj.key
      to = obj.key.gsub(search,replace)
      puts "****** renaming #{from} to #{to}"
      obj.rename(to,:access => 'public_read')
      puts '****** done'
    end
    nil
  end
  def self.connect_and_create_bucket(bucket_name)
    xml_file_location = Rails.root + 'lib/tasks/crossdomain.xml'
    puts "Your bucket name is #{bucket_name}"
    if S3Config.connect_to_s3
      if AWS::S3::Bucket.list.map{|x| x.name}.include? bucket_name
        puts "Bucket #{bucket_name} exists already! Skipping."
        if File.exists?(xml_file_location)
          AWS::S3::S3Object.store('crossdomain.xml', open(xml_file_location), bucket_name)
          puts 'Crossdomain.xml file added.'
        else
          puts "I couldn't find crossdomain.xml file. It should be in lib/tasks."
        end

      else
        puts "Creating Bucket #{bucket_name}"
        if AWS::S3::Bucket.create(bucket_name)
          puts 'Bucket created. Adding crossdomain.xml file.'
          if File.exists?(xml_file_location)
            AWS::S3::S3Object.store('crossdomain.xml', open(xml_file_location), bucket_name)
            puts 'Crossdomain.xml file added.'
          else
            puts "I couldn't find crossdomain.xml file. It should be in lib/tasks."
          end
        else
          puts "I couldn't create #{bucket_name}"
        end
      end
    end
  end
end
