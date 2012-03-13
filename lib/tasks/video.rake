namespace :video do
  desc 'Saying Something'
  task :say_hi do
    puts 'say something'
    x = STDIN.gets.chomp!
    puts 'Hi you said' + x.to_s
  end
end