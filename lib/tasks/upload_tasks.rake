namespace :piecemaker do
  require Rails.root.to_s + '/config/environment'

  def get_files_from_directory(dir_name)
    Dir.chdir(dir_name)
    Dir.glob('*').select{|x| ['mp4','mov'].include?(x.split('.').last)}
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
    compressable_files = Video.uncompressed_files
    puts compressable_files.length.to_s + ' files'
    compressable_files.each do |x|
      puts x.title
    end
  end
  desc 'Compress Compressable Videos'
  task :compress_compressable do
    Video.compress_compressable
  end

  desc 'List Uploadable Compressed Files'
  task :list_uploadable do
    Video.list_uploadable
  end
  desc 'Upload files from compressed folder to S3'
  task :upload_uploadable do
    Video.upload_uploadable
  end
end
=begin
  TODO startup_tasks: create folders, create s3 bucket, seed db
  everyday_tasks: compress compressable, upload compressed
=end