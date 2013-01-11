source 'https://rubygems.org'

gem 'rails', '~> 3.2.11'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'aws-s3', :require => 'aws/s3'
#gem 'acts-as-list', :require => 'acts_as_list'
gem 'haml'
gem 'sass'
#gem "heroku", "~> 2.21.3"
gem "pg", "~> 0.13.2"
#gem 'rake', '0.9.2.2'
#gem 'rdoc'
#gem 'delayed_job_active_record'
#gem 'active_record_query_trace'
gem 'ancestry'
gem 'thin'
gem 'term-ansicolor'
group :development do
  gem 'annotate', ">=2.5.0"
  gem 'taps'
end

gem 'rspec-rails', '~> 2.9.0',  :group => [:test, :development, :cucumber]
gem 'factory_girl_rails', '~> 3.0.0' ,:group => [:test, :cucumber]

group :test do
  gem 'capybara'           # better than webrat
  gem 'guard-rspec'
  gem 'database_cleaner'   # clean database between tests
  gem 'cucumber-rails'
  gem 'cucumber'
end
group :cucumber do

end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'mustache'


# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
