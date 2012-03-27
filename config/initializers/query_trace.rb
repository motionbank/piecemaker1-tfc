require Rails.root + 'lib/query_trace/query_trace'

class ::ActiveRecord::LogSubscriber
  include QueryTrace if Rails.env.development?
end