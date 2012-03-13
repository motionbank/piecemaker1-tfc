class Location < ActiveRecord::Base
  has_one :configuration
end

# == Schema Information
#
# Table name: locations
#
#  id       :integer(4)      not null, primary key
#  location :string(255)
#

