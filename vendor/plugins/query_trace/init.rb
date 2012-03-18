require 'query_trace'

class ::ActiveRecord::LogSubscriber
  include QueryTrace if Rails.env.development?
end