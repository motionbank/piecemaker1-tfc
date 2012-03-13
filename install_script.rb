#! /usr/bin/ruby
require 'fileutils'
def get_arch_type
  var = `uname -m`
  var =~ /x86_64/ ? '64' : '32'
end
def current_folder 
  @cf ||= Dir.pwd
end
ENV_VARIABLES_TEXT = <<-END
PassengerPoolIdleTime 0
SetEnv APP_LOCATION dev
SetEnv PSEUDOSTREAM_TYPE local_plain
SetEnv ARCH_TYPE #{get_arch_type}
END

VIRTUAL_HOST_TEXT = <<-END
NameVirtualHost *:80

<VirtualHost *:80>
  ServerName piecemaker
  DocumentRoot "#{current_folder}/public"
</VirtualHost>
END
## extra stuff
# <directory "#{current_folder}/public">
#   AllowOverride all
#   Options FollowSymLinks
#   Order allow,deny
#   Allow from all
# </directory>





def sudome
  if ENV["USER"] != "root"
    puts "To install piecemaker I need to have your administrators password."
    exec("sudo #{ENV['_']} #{ARGV.join(' ')}")
  end
end

def apache_virtual_server
  avs = <<-END
END
end

def print_welcome
  puts "We're currently in #{current_folder}"
  if current_folder.split('/').last == 'piecemaker'
    true
  else
    puts "You don't seem to be in the piecemaker folder. Should I continue anyway? Type Y for yes."
    if %w[Y y Yes yes YES].include? gets.chomp
      true
    else
      false
    end
  end
end

def apache_path 
  '/private/etc/apache2'
end
def apache_conf_path
  apache_path+'/httpd.conf'
end
def check_apache_path
  if File.exists?(apache_path)
    if File.exists?(apache_conf_path)
      puts "Apache conf file exists."
      true
    else
      puts "There's no conf file."
      false
    end
  else
    puts "I can't find the apache directory."
    false
  end
end

def backup_apache_conf_file
    backup_path = apache_conf_path + '.before_piecemaker'
    puts "Backing up apache conf to #{backup_path}"
    FileUtils.cp(apache_conf_path, backup_path)
end

def install_passenger
  puts 'Installing Passenger Gem.'
  system 'gem install passenger'
  output = `yes | passenger-install-apache2-module`
  message = output.split('The Apache 2 module was successfully installed.').last
  message = message.gsub("\e",'')
  message = message.gsub("[0m[37m[40m",'')
  message = message.gsub("[0m[37m[40m",'').gsub("[1m",'')
  firstline  = message.grep(/LoadModule/).first.strip
  secondline = message.grep(/PassengerRoot/).first.strip
  thirdline  = message.grep(/PassengerRuby/).first.strip
  [firstline, secondline, thirdline]
end

def add_passenger_block(conf,patch_text)
  conf << "\n\n# starting piecemaker block.\n"
  conf << "# You may safely remove this block if you don't wish to use piecemaker.\n"
  conf << patch_text[0] + "\n"
  conf << patch_text[1] + "\n"
  conf << patch_text[2] + "\n\n"
  conf << ENV_VARIABLES_TEXT + "\n"
  conf << VIRTUAL_HOST_TEXT + "\n"
  conf << '# end piecemaker block' + "\n"
end

def fix_document_root(conf)
  index = conf.find_index{|x| x =~ /^DocumentRoot "\/Library\/WebServer\/Documents"/}
  conf[index] = '# ' + conf[index]
  conf[index] << "\n"
  conf[index] << "DocumentRoot \"#{current_folder}/public\""
  conf
end

def fix_directory_directive(conf)
  index = conf.find_index{|x| x =~ /^<Directory "\/Library\/WebServer\/Documents">/}
  addon = ''
  addon << "\n\n#added by piecemaker\n\n"
  addon << "<Directory \"#{current_folder}/public\">\n"
  addon << "  Options Indexes FollowSymLinks MultiViews\n"
  addon << "  AllowOverride None\n"
  addon << "  Order allow,deny\n"
  addon << "  Allow from all\n"
  addon << "</Directory>\n\n"
  conf[index] = addon + conf[index]
  conf
end

def create_new_apache_file(patch_text)
  puts "Patching Apache file."
  apache_file = open(apache_conf_path){|f| f.readlines}
  apache_file = fix_document_root(apache_file)
  apache_file = fix_directory_directive(apache_file)
  apache_file = add_passenger_block(apache_file,patch_text)
  File.open(apache_conf_path,'w') do |f|
     f << apache_file
  end
end

def patch_hosts_file
  puts 'Adding piecemaker to /private/etc/hosts File.'
  open('/private/etc/hosts', 'a') { |f|
    f.puts '127.0.0.1 piecemaker'
    f.puts 'fe80::1%lo0 piecemaker'
  }
end

def install_gems
  puts "Istalling Bundler gem"
  system 'gem install bundler'
  system 'gem install rake'
end
def restart_apache
  puts 'Restarting Apache web server.'
  `apachectl graceful`
end

def print_goodbye
  puts "The necessary system software has been installed."
  puts "Now you have to setup the piecemaker database."
  puts "Please type the following: 'rake piecemaker:setup' and hit return."
  puts "After that finishes you should be able to take your browser to http://piecemaker"
  puts "Good Luck"
end

def run(doit = false)
  sudome
  if print_welcome
      if check_apache_path
        install_gems
        backup_apache_conf_file
        patch = install_passenger
        create_new_apache_file(patch)
        patch_hosts_file
        restart_apache
        print_goodbye
      else
        puts 'Aborting. Thank You.'
      end
  else
    puts 'Aborting. Thank You.'
  end
end
run