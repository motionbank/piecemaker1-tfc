namespace :heroku do
  desc "PostgreSQL database backups from Heroku to Amazon S3"
  task :backup => :environment do
    begin
      require 'aws/s3'
      puts "[#{Time.now}] heroku:backup started"
      name = "#{ENV['APP_NAME']}-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}.dump"
      db = ENV['DATABASE_URL'].match(/postgres:\/\/([^:]+):([^@]+)@([^\/]+)\/(.+)/)
      system "PGPASSWORD=#{db[2]} pg_dump -Fc --username=#{db[1]} --host=#{db[3]} #{db[4]} > tmp/#{name}"
      AWS::S3::Base.establish_connection!(
        :access_key_id => ENV['S3_ACCESS_KEY_ID'],
        :secret_access_key => ENV['S3_SECRET_ACCESS_KEY']
      )
      #s3 = RightAws::S3.new(ENV['s3_access_key_id'], ENV['s3_secret_access_key'])
      AWS::S3::S3Object.store(name, open("tmp/#{name}"), 'piecemaker-heroku-backups', :access => :private)
      #bucket = s3.bucket("#{ENV['APP_NAME']}-heroku-backups", true, 'private')
      #bucket.put(name, open("tmp/#{name}"))
      system "rm tmp/#{name}"
      puts "[#{Time.now}] heroku:backup complete"
    # rescue Exception => e
    #   require 'toadhopper'
    #   Toadhopper(ENV['hoptoad_key']).post!(e)
    end
  end
end

task :cron => :environment do
  Rake::Task['heroku:backup'].invoke
end