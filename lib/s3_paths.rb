module S3Paths

    def s3_prefix(new_way=false)
      'tfc' + '/' +self.class.name.downcase
    end
    
    def s3_path(style = 'original')
      return nil unless s3_prefix
      case self.class.name
        when 'Event'
          'tfc/video/' + title
        when 'Photo'
          s3_prefix + "/#{style}/" + (picture_file_name || '')
        when 'Document'
          'tfc/p-' + piece_id.to_s + '/asset/d-' + id.to_s + '/' + (doc_file_name || '')
          #s3_prefix + '/' + (doc_file_name || '')
        when 'Sound'
          s3_prefix + '/' + (title || '')
        else 
          nil
      end
    end

    def s3_ok?
        S3Config.connect_and_get_list.include? s3_path
    end

    def delete_s3(style = 'original')
      bucket = S3Config.bucket
      #begin
        S3Config.connect_to_s3
        if AWS::S3::S3Object.exists?(s3_path(style), bucket)
          logger.warn('found it')
          AWS::S3::S3Object.delete(s3_path(style), bucket)
        else
          logger.warn("******** cant find #{s3_path(style)} on s3")
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