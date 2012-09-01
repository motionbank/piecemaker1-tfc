module VideoHelper
  def show_form?
    user_has_right?('group_admin') #&& @piece
  end

  def flowplayer_provider_string(flow_type)
    case flow_type
    when 's3'
      "provider: 'rtmp',"
    when 's3_plain'
      '' #????
    when 'local_plain'
      ''
    else
      "provider: 'apache2',"
    end
  end
  def flowplayer_type_string(flow_type)
    case flow_type
    when 's3'
      ",rtmp:{url: '/swfs/flowplayer.rtmp-3.2.3.swf',netConnectionUrl:'rtmp://#{S3Config.cloudfront_address}'}"
    when 's3_plain'
      ""
    when 'local_plain'
      ''
    else
      ",apache2:{url: 'flowplayer.pseudostreaming-3.2.7.swf'}"
    end
  end
  def flowplayer_clip_url(flow_type,video,base_url)
    case flow_type
      when 's3'
        x = video.s3_path.split('.')
        "#{x[1]}:#{x[0]}"




       # "http://s3.amazonaws.com/#{S3Config.bucket}/#{video.s3_path}"#video.full_s3_path
      when 's3_plain'
        "http://s3.amazonaws.com/#{S3Config.bucket}/#{video.s3_path}"
      when 'local'
        "http://#{base_url}#{video.full_local_alias}"
      when 'local_plain'
        "http://#{base_url}#{video.full_local_alias}"
      else
        "http://#{base_url}#{video.full_archive_alias}"
    end
  end
  def flowplayer_div_url(flow_type,video)
    case flow_type
    when 's3'
      "http://#{video.s3_path}"
    when 's3_plain'
      "http://#{video.s3_path}"
    when 'local'
      "http://#{video.full_local_alias}"
    when 'local_plain'
      "http://#{video.full_local_alias}"
    else
      "http://#{Video.archive_path}/#{video.title}"
    end
  end
end
