class NilClass
  def to_time_string
    'warning no video!'
  end
end
class Fixnum
  def self.zero_pad(num)
    num < 10 ? '0' + num.to_s : num.to_s
  end
  def to_time_string
    timestring = ''
    hourmin = self.to_i.divmod(3600)
    minsec = hourmin[1].divmod(60)
    timestring << Fixnum.zero_pad(hourmin[0])+'h' if hourmin[0] > 0
    timestring << Fixnum.zero_pad(minsec[0])+'m'
    timestring << Fixnum.zero_pad(minsec[1])+'s'
  end
end
class Float
  def to_time_string
    self.to_i.to_time_string
  end
end
module ActiveRecord
  class Base
    def s3_prefix(new_way=false)
      return nil unless SetupConfiguration.s3_base_folder
      string = ''
      string << SetupConfiguration.s3_base_folder
      case self.class.name
        when 'Video'
          string << "/video"
        when 'Photo'
          return nil unless piece_id
          string << "/p-#{piece_id}/photo/ph-#{id}"
        when 'Document'
          return nil unless piece_id
          string << "/p-#{piece_id}/asset/d-#{id}"
        when 'Sound'
          return nil unless piece_id
          string << "/p-#{piece_id}/sound/b-#{id}"
        else 
          ""
      end
      string
    end
    def s3_path(style = 'original')
      return nil unless s3_prefix
      case self.class.name
        when 'Video'
          s3_prefix + '/' + title
        when 'Photo'
          s3_prefix + "/#{style}/" + (picture_file_name || '')
        when 'Document'
          s3_prefix + '/' + (doc_file_name || '')
        when 'Sound'
          s3_prefix + '/' + (title || '')
        else 
          nil
      end
    end
  
    def s3_ok?
        S3Config.connect_and_get_list.include? s3_path
    end
  
    # def s3_ok? #tells if the uploaded video is really where it should be on s3    
    #   if S3Config.connect_to_s3
    #     ok = AWS::S3::S3Object.exists?(self.s3_path,S3Config.bucket) 
    #   else
    #     return false
    #   end
    # end
    # 

    def delete_s3(style = 'original')
      bucket = S3Config.bucket
      #begin
        S3Config.connect_to_s3
        if AWS::S3::S3Object.exists?(s3_path(style), bucket)
          logger.warn('found it')
          AWS::S3::S3Object.delete(s3_path(style), bucket)
        else
          logger.warn("******** cant find #{s3_path(style)}")
          message = "Deleted item id: #{id} but i couldn't find the s3 object #{s3_path(style)}"
          Message.create(
          :user_id => 1,
          :from_id => 0,
          :message => message)
          true
        end
      #rescue
        #logger.error('i was not able to connect to s3')
        #false
      #end
    end
    
  end
end
