module VideoHelper
  def show_form?
    user_has_right?('group_admin') #&& @piece
  end

  def video_form_stuff
    stuff = ''
    stuff << form_tag( :action => 'give_videos_to_piece',:order => @order, :page => params[:page], :sorter => params[:sorter])
    stuff << hidden_field_tag('pid', params[:id])
    stuff << submit_tag('Go')
    arrayx = [
      ['Performance','performance'],
      ['Rehearsal','rehearsal'],
      ['Other','other'],
      ['Give to Piece','give']]
    if ENV['APP_LOCATION'] != 'heroku' 
      arrayx += [['Get Meta Data','data'],
      ['Confirm Files','check'],
      ['Archive to Local','dearchive'],
      ['Local to Archive','archive'],
      ['Local to S3', 'upload'],
      ['Archive to Compress and Upload','move']]
    end
     stuff << select_tag('action_type', options_for_select(arrayx))
     stuff << select_tag('piece', options_from_collection_for_select(@pieces.sort_by{|x| x.title}, 'id', 'title'))
     stuff
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
        video.full_s3_path
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
