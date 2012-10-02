namespace :piecemaker do

  desc 'Do all piecemaker setup tasks'
  task :setup => [ 'piecemaker:create_video_folders','db:setup' ]
  
  desc 'Creating Video Folders'
  task :create_video_folders do
    Dir.chdir(Rails.root.to_s + '/public')
    if !File.exists? video_base_folder
      puts "Creating #{video_base_folder}."
      Dir.mkdir(video_base_folder,0777)
    else
      puts "Directory #{video_base_folder} exists already. Skipping."
    end
    Dir.chdir(Rails.root.to_s + '/public/' + video_base_folder)
    %w[full compressed temp backup].each do |fold|
      if !File.exists? fold
        puts "Creating #{fold}."
        Dir.mkdir(fold,0777)
      else
        puts "Directory #{fold} exists already. Skipping."
      end
    end
  end

  desc 'Create a bucket on S3'
  task :create_s3_bucket do
    bucket_name = ENV['S3_BUCKET']
    if bucket_name
      puts "Your bucket name is #{bucket_name}"
      if S3Config.connect_to_s3
        if AWS::S3::Bucket.list.map{|x| x.name}.include? bucket_name
          puts "Bucket #{bucket_name} exists already!"
        else
          puts "Creating Bucket #{bucket_name}"
            if AWS::S3::Bucket.create(bucket_name)
              puts 'Bucket created.'
              puts 'Adding crossdomain.xml file.'
              if File.exists?(RAILS_ROOT + '/lib/tasks/crossdomain.xml')
                AWS::S3::S3Object.store('crossdomain.xml', open(RAILS_ROOT + '/lib/tasks/crossdomain.xml'), bucket_name)
                
              else
                puts "I couldn't find crossdomain.xml file. It should be in lib/tasks."
              end
            else
              puts "I couldn't create #{bucket_name}"
            end
        end
      else
        puts "I couldn't connect to s3"
      end
    else
      puts 'please set your s3 bucket environment variable and retry'
    end
  end

end