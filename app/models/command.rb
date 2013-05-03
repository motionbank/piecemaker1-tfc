class Command < ActiveRecord::Base
  # attr_accessible :title, :body
  serialize :event_data
  belongs_to :event
end
