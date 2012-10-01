# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  happened_at    :datetime
#  dur            :integer
#  event_type     :string(255)
#  video_id       :integer
#  piece_id       :integer
#  locked         :string(255)      default("none"), not null
#  state          :string(255)      default("normal")
#  description    :text
#  created_by     :string(255)
#  modified_by    :string(255)
#  updated_at     :datetime
#  performers     :text
#  created_at     :datetime
#  highlighted    :boolean          default(FALSE)
#  inherits_title :boolean          default(FALSE)
#  location       :string(255)
#  rating         :integer          default(0)
#  parent_id      :integer
#

require 'spec_helper'
describe Event do
  pending "add some examples to (or delete) #{__FILE__}"
end
