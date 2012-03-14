# # Put this in config/application.rb
# require File.expand_path('../boot', __FILE__)
# 
# module Piecemakerlite
#   class Application < Rails::Application
#     # Settings in config/environments/* take precedence over those specified here
#   
#     # Skip frameworks you're not going to use (only works if using vendor/rails)
#     # config.frameworks -= [ :action_web_service, :action_mailer ]
#   
#     # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
#     # config.plugins = %W( exception_notification ssl_requirement )
#   
#     # Add additional load paths for your own custom dirs
#      config.autoload_paths += %W( #{RAILS_ROOT}/app/extras )
#   
#     # Force all environments to use the same logger level
#     # (by default production uses :info, the others :debug)
#     # config.log_level = :debug
#   
#     config.action_controller.session = {
#       :key => '_piecemaker_session_id_1',
#       :secret      => 'caa79c5cb34e829cf8cc04b439c542e6313d635cc564926fc49948cac512fe150f0ecea9e0c331bdad9e5687da8c58e7fadceae29981d64218e7cb631a4db98a'
#     }
#   
#   
#     # Use the database for sessions instead of the file system
#     # (create the session table with 'rake db:sessions:create')
#      #config.action_controller.session_store = :active_record_store
#   
#     # Use SQL instead of Active Record's schema dumper when creating the test database.
#     # This is necessary if your schema can't be completely dumped by the schema dumper,
#     # like if you have constraints or database-specific column types
#     # config.active_record.schema_format = :sql
#   
#     # Activate observers that should always be running
#     # config.active_record.observers = :cacher, :garbage_collector
#   
#     # Make Active Record use UTC-base instead of local time
#      config.active_record.default_timezone = :utc
#      config.time_zone                      = 'Rome'
#      config.action_mailer.raise_delivery_errors = true
#     # Add new inflection rules using the following format
#     # (all these examples are active by default):
#     # Inflector.inflections do |inflect|
#     #   inflect.plural /^(ox)$/i, '\1en'
#     #   inflect.singular /^(ox)en/i, '\1'
#     #   inflect.irregular 'person', 'people'
#     #   inflect.uncountable %w( fish sheep )
#     # end
#   
#     # See Rails::Configuration for more options
#     # config.gem 'aws-s3', :lib => 'aws/s3'
#     # config.gem 'prawn'
#     # #config.gem 'pbosetti-rubyosa', :lib => 'rbosa'
#     # #config.gem 'rb-appscript', :lib => 'appscript'
#     # #config.gem 'rmagick'
#     # config.gem 'acts-as-list', :lib => 'acts_as_list'
#     # #config.gem 'RedCloth',:lib => 'redcloth'
#     # #config.gem "mime-types", :lib => "mime/types"
#     # #config.gem "searchlogic"
#     # #config.gem 'thoughtbot-paperclip'
#     # config.gem 'will_paginate'
#     # config.gem 'mysql'
#     # config.gem 'haml'
#   end
#   
#   # Add new mime types for use in respond_to blocks:
#   # Mime::Type.register "text/richtext", :rtf
#   # Mime::Type.register "application/x-mobile", :mobile
#   
#   # Include your application configuration below
#   
#   ActionMailer::Base.delivery_method = :smtp
#   
#   if $0 == 'irb'
#       require 'hirb'
#       Hirb.enable
#   end
# end