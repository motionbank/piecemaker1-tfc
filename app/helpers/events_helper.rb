module EventsHelper


  def event_type_select_options(event)
    types = Array.new
    Event.event_types.each do |x|
      types << [x.humanize,x]
    end 
    return options_for_select(types,event.event_type)
  end
  

  def events_performers(event)
    events_performers = event.performers[0] == 'Everyone' ? current_piece.performers.map{|x| x.short_name}.sort : event.performers
  end
  def put_date(event)
    event.happened_at.at_midnight.strftime("%Y %m %d")
  end
  def video_ended(ref,event)
    return false unless ref
    return true if ref.video && !event.video
    return true if ref.video && ref.video != event.video
    false
  end
  def video_starting(ref,event)
    return false if !ref && !event.video
    return true if !ref && event.video
    return true if !ref.video && event.video
    return true if ref.video && event.video && ref.video != event.video
    false
  end
  def open_video_block(event)
    text = "<div style = 'background:#ccc'>"
    text << "<h3>#{event.video.title} id: #{event.video_id.to_s}</h3>"
    text
  end
  def close_video_block
    '</div><br />'
  end
end
