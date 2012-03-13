class DelayedJob < ActiveRecord::Base

end

# == Schema Information
#
# Table name: delayed_jobs
#
#  id         :integer(4)      not null, primary key
#  priority   :integer(4)      default(0)
#  attempts   :integer(4)      default(0)
#  handler    :text
#  last_error :text
#  run_at     :datetime
#  locked_at  :datetime
#  failed_at  :datetime
#  locked_by  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

