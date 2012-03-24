class SetupConfiguration < ActiveRecord::Base
serialize :file_locations
acts_as_tenant(:account)
  def self.s3_base_folder
    @@s3b ||= first.s3_sub_folder
  end

  def self.cdn?
    true
  end
  def self.pseudostreaming_type
    ENV['PSEUDOSTREAM_TYPE'] || 'local_plain'
  end
  
  def self.app_is_local?
    false # ENV['APP_LOCATION'] != 'heroku' #'server' heroku
  end

  def users
    User.all
  end
  def pieces
    Piece.all
  end

  def self.no_video_string
    '<span style="color:#f00">No Video</span>'
  end
  def self.event_types
    %w[discussion headline light_cue performance_notes scene sound_cue dev_notes marker video]
  end
  def self.roles
    %w[group_admin manager user guest]
  end
  def self.rights
    {
      'group_admin'         => %w[group_admin],
      'advanced_actions'   => %w[group_admin manager user],
      'normal_actions'       => %w[group_admin user],
      'normal_actions'       => %w[group_admin user],
      'normal_actions' => %w[group_admin user],
      'highlight'           => %w[group_admin manager user],
      'view_dev_notes'      => %w[group_admin]
    }
  end
  def self.field_types
    %w[enabled title creation_info description performers edit_links media_time tags]
  end
  def self.truncate_length
    300
  end
  def self.found_text_replacement_string
    '<span class="found">\1</span>'
  end
end

# == Schema Information
#
# Table name: configurations
#
#  id               :integer(4)      not null, primary key
#  time_zone        :string(255)
#  use_auto_video   :boolean(1)      default(FALSE)
#  created_at       :datetime
#  updated_at       :datetime
#  read_only        :boolean(1)      default(FALSE)
#  use_heroku       :boolean(1)      default(FALSE)
#  s3_sub_folder    :string(255)
#  default_piece_id :integer(4)
#  file_locations   :text
#

