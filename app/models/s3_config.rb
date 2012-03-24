class S3Config

  def self.access_key_id     
    ENV['S3_ACCESS_KEY_ID']
  end
  def self.secret_access_key 
    ENV['S3_SECRET_ACCESS_KEY']
  end
  def self.bucket            
    'piecemakerlite'
  end
  def self.max_file_size     
    ENV['S3_SWF_MAX_FILE_SIZE'] || 535544320
  end
  def self.acl               
    ENV['S3_SWF_UPLOAD_ACL'] || 'public-read'
  end
  def self.cloudfront_address
    's3bulcu47zau6v.cloudfront.net/cfx/st'
  end

  
  def self.connect_to_s3
    begin
    result = AWS::S3::Base.establish_connection!(
    :access_key_id     => S3Config.access_key_id,
    :secret_access_key => S3Config.secret_access_key
      )
    rescue
      return false
    end
  end

  def self.connect_and_get_bucket
    begin
      S3Config.connect_to_s3
      connection_bucket = AWS::S3::Bucket.find(S3Config.bucket)
    rescue
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
