class SetupConfiguration

  def self.time_zone
    'Berlin'
  end
  def self.quicktime_player
    'QuickTime Player 7'
  end
  def self.cdn?
    true
  end
  def s3_sub_folder
    'tfc'
  end
  def self.app_is_local?
    ENV['APP_LOCATION'] != 'heroku' #'server' heroku
  end
  def self.use_auto_video?
    app_is_local?
  end

  def users
    User.all
  end
  def pieces
    Piece.all
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
      'normal_actions'       => %w[group_admin manager user],
      'highlight'           => %w[group_admin manager user],
      'view_dev_notes'      => %w[group_admin]
    }
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

