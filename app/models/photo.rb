
class Photo < ActiveRecord::Base
  require 's3_paths'
  include S3Paths
  
  belongs_to :piece
  def new_name
    false
  end
  def create_from_params(params)
    self.picture_file_name = params[:title]
    self.path = params[:prefix]
    self.picture_file_size = params[:size]
    self.picture_content_type = params[:contenttype]
    save
  end
  def destroy_all_styles
    did = false
    ['original','thumbnail'].each do |style|
      if self.delete_s3(style)
        did = true
      end
    end
    true
  end
  
  def self.create_thumbnail(original_photo,style='thumbnail')
    include Magick
    original_path = original_photo.s3_path('original')#original_photo.path + "/original/" + original_photo.picture_file_name
    thumbnail_path = original_photo.s3_path(style)#original_photo.path + "/#{style}/" + original_photo.picture_file_name
    s3_bucket = S3Config.bucket
    S3Config.connect_to_s3
    ori_temp = File.new('tmp/original.jpg','w')
    ori_temp.write(AWS::S3::S3Object.value(original_path, s3_bucket))###
    ori_temp.close
    ori_obj = ImageList.new('tmp/original.jpg')
    thumb_obj = ori_obj.resize_to_fit(200,200)
    thumb_obj.write('tmp/thumb.jpg')
    AWS::S3::S3Object.store(thumbnail_path, open('tmp/thumb.jpg'), s3_bucket, :access => :public_read)
    system('rm tmp/original.jpg')
    system('rm tmp/thumb.jpg')
    original_photo.has_thumb = true
    original_photo.save
        
  end

end


# == Schema Information
#
# Table name: photos
#
#  id                   :integer(4)      not null, primary key
#  picture_file_name    :string(255)
#  picture_content_type :string(255)
#  picture_file_size    :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#  piece_id             :integer(4)
#  path                 :string(255)
#  has_thumb            :boolean(1)      default(FALSE)
#

