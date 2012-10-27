# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def found_text_replacement_string
    Piecemaker.config.found_text_replacement_string || '<span class="found">\1</span>'
  end
  def truncate_length
    Piecemaker.config.truncate_length || 300
  end
  def error_messages_for(thing)
    if thing.errors.any?
      text = '<ul>'
        thing.errors.full_messages.each do |msg|
          text << '<li>' + msg + '</li>'
        end
      text << '</ul>'
    end
  end

  def came_from_string
    @cf ||= '?came_from='+@came_from.to_s.gsub('/','%2F')
  end
  def taglist
    taglist = ['select some tags from this list']
    taglist += current_piece.owned_tags.uniq
  end
  def put_search_field(options)
    return '' unless options
    text = ''
    text << form_tag(:action => params[:action],:id => params[:id],:order => params[:order], :sort => params[:sort], :search_field => options)
    text << "Search: "
    text << text_field_tag('search_term')
    text << submit_tag("Filter #{options}")
    text << '</form>'
    text
  end
  def wrap_boolean(text)
    if ['true','false'].include? text
      text = text == 'false' ? '<span style = "color:#a00">No</span>' : '<span style = "color:#0a0">Yes</span>'
    else
      text
    end
  end


  def checklist(model,collection,fields,checked_collection=[],checked_field=nil,show_check_all = true,reset_number = 8)
    #this works in conjunction with the javascript in application.js
    checked_ids = checked_field ? checked_collection.map{|x| eval("x.#{checked_field}")} : checked_collection
    text = "<div id = '#{model}'>"
    counter = 1
    if fields.length == 2
      full_list = collection.collect {|x| {fields[0] => eval("x.#{fields[0]}") ||'',fields[1] => eval("x.#{fields[1]}")||''}}.sort_by {|x| x['login']}
    else
      full_list = collection.collect{|x| eval("x.#{fields[0]}")}.sort
    end
    full_list.each do |item|
      if fields.length == 2
        text << check_box_tag("#{model}", item[fields[0]], checked_ids.include?(item[fields[0]]), :class => "check_all_able #{model.gsub(']','').gsub('[','')}") + '' + item[fields[1]]
      else
        text << check_box_tag("#{model}", item, checked_ids.include?(item), :class => "check_all_able #{model.gsub(']','').gsub('[','')}") + '' + item
      end
      if counter == reset_number
        text << '<br />'
        counter = 0
      else
        text << '&nbsp;&nbsp;'
      end
      counter += 1
    end
    text << '<br /><br />'
    text << "<input type='checkbox' class = 'check-all #{model.gsub(']','').gsub('[','')}' name=''/>Select / De-select All" if show_check_all
    text << '</div>'
  end

  def put_select_all_checkbox(name='')
    "<input type='checkbox' class = 'check-all #{name.gsub(']','').gsub('[','')}' name=''/>Select / De-select All"
  end


  def put_viewer_sub_menu
    text = "<ul id = \"viewsubmenlist\">"
    text << "<li><a class='get pause' href='/sub_scene/edit_sub_annotation/' >Edit</a></li>"
    text << "</ul>"
  end


  def menu_first_level(title, &block)
  content = with_output_buffer(&block)
  menu_open_first_level(title) + content + menu_close_first_level
  end

  def menu_open_first_level(title)
    html = raw "<li><a>" + title + '</a>' + "<ul>\n"#opens list of menu items
  end
  def menu_close_first_level
    html = raw "</ul></li>\n"
  end

  def menu_second_level(tip, title, &block)
    content = with_output_buffer(&block)
    menu_open_second_level(tip, title) + content + menu_close_second_level
  end

  def menu_open_second_level(tip, title)
    html = raw "<li><a class='drop' href='#' title='" + tip + "'>" + title + "</a>\n"
    html2 = raw "<ul class = 'right'>\n" #opens second level list
    html = html + html2
  end

  def menu_close_second_level
    html =  raw "</ul>\n</li>"
  end

  def display_duration_select(label, duration, prefix = 'duration')
    duration_hash = duration_to_hash(duration)
    string = "<b>" + label + "</b>"
    string << '&nbsp;'
    string << 'Hours: '
    string << select_hour(duration_hash[:hours], :prefix => prefix)
    string << 'Minutes: '
    string << select_minute(duration_hash[:minutes], :prefix => prefix)
    string << 'Seconds: '
    string << select_second(duration_hash[:seconds], :prefix => prefix)
    content_tag :p, string
  end

  def display_menu_link(item,menu_name,size = '',tag = 'div', rate = false)
    return '' unless user_has_right?('normal_actions')
    text = "<#{tag} class = 'menu-link #{size}'>"
    text << " <a class = 'jsc'href='' data-id='#{item.id.to_s}' data-menuName='#{menu_name}'>MENU...</a>"
    text << display_rating(item) if rate
    text << "</#{tag}>"
  end
  def display_video_menu(video)
    text = "<div id = 'm-#{video.id}'class='menu-link'>"
    video.rating.times do
      text << '<span>* </span>'
    end
    text << " <a class='jsc'href=''data-id='#{video.id.to_s}' data-menuName='vidm'>MENU...</a>"
    text << "</div>"
    text
  end


  def piece_select_with_none
    start = [['None', '']]
    start += Pieces.all.map{|x| [x.title,x.id]}
  end

  def put_role_select(selected)
   roleids = Hash.new
   SetupConfiguration.roles.each do |role|
     roleids[role] = role
   end
    text = "Role: "+select_tag('user[role_name]', options_for_select(roleids,selected))+'<br /><br />'
  end

  def demo_mode
    session[:demo_mode]
  end

  def span_if_here(cont,act,text)
    if((params[:controller] == cont) && (params[:action] == act)) #
      text_string = "<span id = 'disabled'><a>#{text}</a></span>"
    else
      text_string = link_to(text, :controller => cont, :action => act)
    end
  end


  def put_photo(photo,style)
    style = (style == 'thumbnail' && photo.has_thumb) ? style : 'original'
    full_path = "http://s3.amazonaws.com/#{s3_bucket}/#{photo.s3_path}"
    thumb_path = "http://s3.amazonaws.com/#{s3_bucket}/#{photo.s3_path(style)}"
    "<a class= 'photo-link'style='padding:0px; background:none;color:#f00;text-decoration:underline;'href = '#{full_path}'><img src = '#{thumb_path}' width ='200'></a>"
  end

  def put_photo_caption(photo)
    text = '<br />'
    unless photo.has_thumb
      text << 'full '
    end
    if user_has_right?('normal_actions')
      text << link_to('delete',{:action => 'delete_from_gallery',:id => photo.id},:class => 'dgdelp',:id => photo.id)
    end
  end

  def s3_swf_upload_tag_new(options = {})
    buttonWidth             = options[:buttonWidth]  || 100
    buttonHeight            = options[:buttonHeight] || 30
  	flashVersion            = options[:height] || '9.0.0'
  	queueSizeLimit          = options[:queueSizeLimit] || 100
  	fileSizeLimit           = options[:fileSizeLimit] || 524288000
    fileTypes               = options[:fileTypes] || '*.*'
    fileTypeDescs           = options[:fileTypeDescs] || 'All Files'
    selectMultipleFiles     = options.has_key?(:selectMultipleFiles) ? options[:selectMultipleFiles] : false
    keyPrefix               = options[:keyPrefix] || ''
  	signaturePath           = options[:signaturePath] || '/s3_uploads'
  	buttonUpPath            = options[:buttonUpPath] || '/swfs/s3_up_button.gif'
  	buttonOverPath          = options[:buttonOverPath] || '/swfs/s3_over_button.gif'
  	buttonDownPath          = options[:buttonDownPath] || '/swfs/s3_down_button.gif'

  	onFileAdd							  = options[:onFileAdd] || false
  	onFileRemove						= options[:onFileRemove] || false
  	onFileSizeLimitReached 	= options[:onFileSizeLimitReached] || false
  	onFileNotInQueue				= options[:onFileNotInQueue] || false

  	onQueueChange						= options[:onQueueChange] || false
  	onQueueClear						= options[:onQueueClear] || false
  	onQueueSizeLimitReached	= options[:onQueueSizeLimitReached] || false
  	onQueueEmpty						= options[:onQueueEmpty] || false

  	onUploadingStop					= options[:onUploadingStop] || false
  	onUploadingStart				= options[:onUploadingStart] || false
  	onUploadingFinish				= options[:onUploadingFinish] || false

  	onSignatureOpen					= options[:onSignatureOpen] || false
  	onSignatureProgress			= options[:onSignatureProgress] || false
  	onSignatureHttpStatus		= options[:onSignatureHttpStatus] || false
  	onSignatureComplete			= options[:onSignatureComplete] || false
  	onSignatureSecurityError= options[:onSignatureSecurityError] || false
  	onSignatureIOError			= options[:onSignatureIOError] || false
  	onSignatureXMLError			= options[:onSignatureXMLError] || false

  	onUploadOpen						= options[:onUploadOpen] || false
  	onUploadProgress				= options[:onUploadProgress] || false
  	onUploadHttpStatus			= options[:onUploadHttpStatus] || false
  	onUploadComplete				= options[:onUploadComplete] || false
  	onUploadIOError					= options[:onUploadIOError] || false
  	onUploadSecurityError		= options[:onUploadSecurityError] || false
  	onUploadError						= options[:onUploadError] || false

    @include_s3_upload ||= false
    @count ||= 1

    out = ''

    if !@include_s3_upload
      out << javascript_include_tag('s3_upload_new')
      @include_s3_upload = true
    end

    out << "\n<script type=\"text/javascript\">\n"
    out << "var s3_swf_#{@count}_object = s3_swf_init('s3_swf_#{@count}', {\n"
    out << "buttonWidth: #{buttonWidth},\n" if buttonWidth
    out << "buttonHeight: #{buttonHeight},\n" if buttonHeight
    out << "flashVersion: '#{flashVersion}',\n" if flashVersion
    out << "queueSizeLimit: #{queueSizeLimit},\n" if queueSizeLimit
    out << "fileSizeLimit: #{fileSizeLimit},\n" if fileSizeLimit
    out << "fileTypes: '#{fileTypes}',\n" if fileTypes
    out << "fileTypeDescs: '#{fileTypeDescs}',\n" if fileTypeDescs
    out << "selectMultipleFiles: #{selectMultipleFiles.to_s},\n"
    out << "keyPrefix: '#{keyPrefix}',\n" if keyPrefix
    out << "signaturePath: '#{signaturePath}',\n" if signaturePath
    out << "buttonUpPath: '#{buttonUpPath}',\n" if buttonUpPath
    out << "buttonOverPath: '#{buttonOverPath}',\n" if buttonOverPath
    out << "buttonDownPath: '#{buttonDownPath}',\n" if buttonDownPath

    out << %(onFileAdd: function(file){
              #{onFileAdd}
            },) if onFileAdd
    out << %(onFileRemove: function(file){
              #{onFileRemove}
            },) if onFileRemove
    out << %(onFileSizeLimitReached: function(file){
              #{onFileSizeLimitReached}
            },) if onFileSizeLimitReached
    out << %(onFileNotInQueue: function(file){
              #{onFileNotInQueue}
            },) if onFileNotInQueue

    out << %(onQueueChange: function(queue){
              #{onQueueChange}
            },) if onQueueChange
    out << %(onQueueSizeLimitReached: function(queue){
              #{onQueueSizeLimitReached}
            },) if onQueueSizeLimitReached
    out << %(onQueueEmpty: function(queue){
              #{onQueueEmpty}
            },) if onQueueEmpty
    out << %(onQueueClear: function(queue){
              #{onQueueClear}
            },) if onQueueClear

    out << %(onUploadingStart: function(){
              #{onUploadingStart}
            },) if onUploadingStart
    out << %(onUploadingStop: function(){
              #{onUploadingStop}
            },) if onUploadingStop
    out << %(onUploadingFinish: function(){
              #{onUploadingFinish}
            },) if onUploadingFinish

    out << %(onSignatureOpen: function(file,event){
              #{onSignatureOpen}
            },) if onSignatureOpen
    out << %(onSignatureProgress: function(file,progress_event){
              #{onSignatureProgress}
            },) if onSignatureProgress
    out << %(onSignatureSecurityError: function(file,security_error_event){
              #{onSignatureSecurityError}
            },) if onSignatureSecurityError
    out << %(onSignatureComplete: function(file,event){
              #{onSignatureComplete}
            },) if onSignatureComplete
    out << %(onSignatureIOError: function(file,io_error_event){
              #{onSignatureIOError}
            },) if onSignatureIOError
    out << %(onSignatureHttpStatus: function(file,http_status_event){
              #{onSignatureHttpStatus}
            },) if onSignatureHttpStatus
    out << %(onSignatureXMLError: function(file,error_message){
              #{onSignatureXMLError}
            },) if onSignatureXMLError

    out << %(onUploadError: function(upload_options,error){
              #{onUploadError}
            },) if onUploadError
    out << %(onUploadOpen: function(upload_options,event){
              #{onUploadOpen}
            },) if onUploadOpen
    out << %(onUploadProgress: function(upload_options,progress_event){
              #{onUploadProgress}
            },) if onUploadProgress
    out << %(onUploadIOError: function(upload_options,io_error_event){
              #{onUploadIOError}
            },) if onUploadIOError
    out << %(onUploadHttpStatus: function(upload_options,http_status_event){
              #{onUploadHttpStatus}
            },) if onUploadHttpStatus
    out << %(onUploadSecurityError: function(upload_options,security_error_event){
              #{onUploadSecurityError}
            },) if onUploadSecurityError
    out << %(onUploadComplete: function(upload_options,event){
              #{onUploadComplete}
            },) if onUploadComplete
    # This closes out the object (no comma)
    out << "foo: 'bar'"
    out << "});\n"
    out << "</script>\n"
    out << "<div id=\"s3_swf_#{@count}\">\n"
    out << "Please <a href=\"http://www.adobe.com/go/getflashplayer\">Update</a> your Flash Player to Flash v#{flashVersion} or higher...\n"
    out << "</div>\n"

    @count += 1
    out
  end





  def s3_swf_upload_tag(options = {})
    height     = options[:height] || 40
    width      = options[:width]  || 500
    success    = options[:success]  || ''
    failed     = options[:failed]  || ''
    selected   = options[:selected]  || ''
    canceled   = options[:canceled] || ''
    prefix     = options[:prefix] || ''
    upload     = options[:upload] || 'Upload'
    initial_message    = options[:initial_message] || 'Select file to upload...'
    do_checks = options[:do_checks] || "0"

    if do_checks != "1" && do_checks != "0"
      raise "Ooops, do_checks has to be either '0' or '1' (a string)"
    end

    prefix = prefix + "/" unless prefix.blank?

    @include_s3_upload ||= false
    @count ||= 1

    out = ""

    if !@include_s3_upload
      #out << '<script type="text/javascript" src="/assets/s3_upload.js"></script>'
      @include_s3_upload = true
    end


    out << %(<br />
          <script type="text/javascript">
          var s3_swf#{@count} = s3_swf_init('s3_swf#{@count}', {
            width:  #{width},
            height: #{height},
            initialMessage: '#{initial_message}',
            doChecks: '#{do_checks}',
            onSuccess: function(filename, filesize, contenttype){
              #{success}
            },
            onFailed: function(status){
              #{failed}
            },
            onFileSelected: function(filename, size, contenttype){
              #{selected}
            },
          });
      </script>

      <div id="s3_swf#{@count}">
        Please <a href="http://www.adobe.com/go/getflashplayer">Update</a> your Flash Player to Flash v9.0.1 or higher...
      </div>
      <br /><br />
      <div class="s3-swf-upload-link">
      <a href="#uploadform#{@count}" onclick="s3_swf#{@count}.upload('#{prefix}')">#{upload}</a>
      </div>
    )

    @count += 1
    out

  end



  def my_tags(texti) #tested
    if texti
      output = ''
      texti = texti.gsub("\n",'<br />')
      texti = texti.gsub(/@-(.*?)-@/,'<div class = "inline">\1</div>')
      texti = texti.gsub(/~\*(.*?)\*~/,'<i>\1</i>')
      texti = texti.gsub(/\*(.*?)\*/,'<strong>\1</strong>')
      texti = texti.gsub(/~(.*?)~/,'<b>\1</b>')
      output << texti
      output
    else
      ''
    end
  end


  def event_type_select_options(event)
    types = Array.new
    alltypes = current_piece.event_types
    alltypes.each do |x|
      types << [x.humanize,x]
    end
    return options_for_select(types,event.event_type)
  end
  def cancel_path #tested
    cancel_path = @create ? 'cancel_new_ev' : 'cancel_modify'
  end

  def videos_for_select
   videos = [['no media','']]
   videos += current_piece.videos.map{|x| [x.title,x.title]}
  end

  def options_for_video_search
    options = "<option value='no_dvd'>No Video</option>"
    options += options_from_collection_for_select(current_piece.videos, "id", "title")
  end
  def events_performers(event)
    events_performers = event.performers[0] == 'Everyone' ? current_piece.performer_list : event.performers
  end


  def put_edit_tip_block
    string = "<div style = 'position:absolute;top:173px;right:10px;width:90px;height:100px;background:#ddd;padding:4px;font-size:11px'>"
    string << '<strong>* Emphasize *</strong><br />'
    string << '<b>~ bold ~</b><br />'
    string << '<i>~* italic *~</i><br />'
    string << '</div>'
    string
  end
  def display_notes(event)
    text = ''
    event.notes.each do |note|
     text << "<div class='note' id ='note-#{note.id}'>"
      text << display_whole_note(note)
      text << '</div>'
    end
    text
  end
  def display_title(event, search = nil)
    content_tag(:div,:class => "evtit#{event.tagged_with_title? ? ' ital' : ''}") do
      text = event.title ? highlight(sanitize(event.title), search, found_text_replacement_string) : ''
      text << " (#{event.piece.title})" if @show_piece
      text
    end
  end

  def put_see_video_link_around_time(event,time)
    st = "<a class = 'hdble go_to' id = 'go-#{time.to_i}' href = '/video_viewer/#{event.piece_id}/#{event.video_id}?event_id=#{event.id}&seek=#{time.to_i}'>"
    st << "<b>"
    st << time.to_time_string
    st << "</b>"
    st << "</a>"

  end

  def display_vid_info(event)
    text = "<div class='evts'>"
      if event.video_id
        if event.video_viewable?
          text << put_see_video_link_around_time(event,event.video_start_time)
        else
          text << event.video_start_time.to_time_string
        end
      else
        text << Piecemaker.config.no_video_string
      end
    text << '</div>'
  end

  def linked_id(event)
    # if true
    #   "<a href = '/capture/present/#{event.piece_id}?filter_type=one_event&event=#{event.id.to_s}'>#{event.id.to_s}</a>"
    # else
      event.id.to_s
    # end
  end
  def display_creation_info(event)
    by = event.created_by || '???'
    info = "<div class='sm evci'>"
    info << event.happened_at.strftime("%d/%m %H:%M:%S") +' by ' + by + ' ' + linked_id(event)

    info << '</div>'
  end


  def display_rating(event)
    text = ''
    if event.rating > 0
      text << '<br /><span>'
      event.rating.times do
        text << '* '
      end
      text << '</span>'
    end
    text
  end


  def display_description(event,search = nil)
    if (event.description)
      text = "<div class='sm evdes'>"
      tt = my_tags(event.description)
      tt = highlight(tt,search,found_text_replacement_string) if search
      text << tt
      text << '</div>'
    else
      text = ''
    end
  end

  def display_performers(event,search = nil)
    if event.performers && event.performers.length
      text = "<div class='evpe'>"
      text << event.performers.join(' ')
      text << '</div>'
    else
      text = ''
    end

  end

  def display_edit_links(event)
    link_display = "<div class='evedlnk'>"
    link_display << put_undelete_link(event)
    link_display << '</div>'
    link_display
  end

  def display_tags(event)
    non_title_tags = event.tags.reject{|x| x.name == event.title}
    if non_title_tags.length > 0
      string = '<div class = "tag">'
      non_title_tags.each_with_index do |tag, index|
        string << ' <a style = "background:none;color:#fff;" href ="/capture/present/'+event.piece_id.to_s+'?filter_type=tag&taggs='+tag.name+'">'+tag.name+'</a>'
        if index < non_title_tags.length-1
          string << ','
        end
      end
    string << '</div>'
    end
  end

  def put_undelete_link(event)
   "<a class='jsc'id= '#{event.id}'href='/capture/undelete_event/#{event.id}'>Undelete</a>&nbsp;<a class = 'jsc'data-confirmation='Are you sure you wish to delete this event forever?'id= '#{event.id}'href='/capture/destroy_event/#{event.id}'>Destroy Forever</a>&nbsp;"
  end


  def display_note_creation_info(event)
    info = event.created_at.strftime("%d/%m - %H:%M") +' by ' + event.created_by
  end
  def display_whole_note(note)
    text = ''
    text << note.description + '&nbsp;&nbsp;--'
    text << "<span class = 'noteinfo'>#{note.created_by} @ #{note.created_at.strftime("%d/%m - %H:%M")}:</span>&nbsp;&nbsp;"

    text << raw(display_note_edit_links(note))
    text
  end
  def display_note_edit_links(note)
    note_edit_link = ''
    if note.created_by == current_user.login || user_has_right?('advanced_actions')

      note_edit_link << "<a class='jsc get-form' href='/capture/edit_note/#{note.id}'ajt='#note_note#{note.id}'>Edit</a>&nbsp;"
      note_edit_link << "<a class='jsc' data-confirmation = 'Are you sure you want to delete this note?'id='n-#{note.id}' href='/capture/delete_note/#{note.id}'>Delete</a>&nbsp;"
    end
    note_edit_link
  end

  def highlighted_class(event)
      text = ''
      text << ' high' if (event.highlighted == true)
      text << ' user-high' if (event.has_user_highlights?(current_user))
      text
  end
  def title_taglist(event)
    taglist = ['select a title from this list']
    taglist += event.piece_tags.uniq.select{|x| x.tag_type == 'title'}.collect{|x| x.name}
  end

  def title_tag_select_options(event)
    options_for_select(title_taglist(event))
  end


  def inherit_check_or_select(event)
      text = "<select id = 'title-taggs' name ='tag_title'>"
      text <<  title_tag_select_options(event)
      text << '</select>'
  end



  def put_rtf_string(events)
    string = '{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
    {\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\froman\fcharset0 Times-Roman;}{\colortbl;\red255\green255\blue255;}'
    events.each do |event|
      if ['scene'].include?(event.event_type)
        substring = '{\f0\b\fs24 '
        substring << event.title
        substring << '}\par '
        substring << "\n"

        substring << '{\f0\b0\fs24 '
        substring << event.created_at.strftime("%d.%m.%y - %H:%M")
        substring << '}\par'
        substring << "\n"

        substring << '{\f0\b0\fs24 '
        substring << 'DVD '
        substring << event.media_number
        substring << '  '
        substring << mini_minute(event.video_start_time.to_i)
        substring << '}\par \par '
        substring << "\n"
        if event.performers && !event.performers.empty?
          substring << '{\f0\i\fs24 '
          substring << event.performers.join(' ')
          substring << '}\par \par '
          substring << "\n"
        end
        substring << '{\f1\i0\fs24 '
        substring << event.description if event.description
        substring << '}\par \par \par '
        substring << "\n"
        string << substring
      end
    end
    string << '}'
    string
  end


  def video_quick_link(video = nil)
    text = ''
    if video_in?
      vvid = video ? video.id.to_s : video_in?.id.to_s
      text << '<span class="short-cut">I </span><a data-confirmation="Stop the Video?"id = "vidinout" class = "jsc hdble vout" href = "/capture/confirm_video_out/'+vvid+'">Stop Video</a>'
    else
      text << '<span class="short-cut">I </span><a id = "vidinout" class = "jsc get-form hdble vprep" href = "/capture/new_auto_video_in/'+current_piece.id.to_s+'">Prepare Video</a>'
      #text << '<br /><span class="short-cut">B </span><a id = "vidinout" class = "get hdble vprep" href = "/capture/new_auto_video_in/'+current_piece.id.to_s+'?quick_take=true">Prep. Vid & Scene</a>'
    end
    text
  end

  def mini_minute(time)
    hourmin = time.divmod(3600)
    minsec = hourmin[1].divmod(60)
    timestring = ''
    if(hourmin[0] > 0)
      timestring << hourmin[0].to_s+'h'
    end
    if(minsec[0] > 0)
      timestring << minsec[0].to_s+'m'
    end
    timestring << minsec[1].to_s+'s'
    timestring
  end

  def put_date(date,i)
    '<div id = "dat-'+i.to_s+'" style = "color:#d00;font-size:20px;margin-left:-25px">' + date.strftime("%A %d %b %Y")+'</div>'
  end

  def open_video_html(video)
    running = video.dur ? "Duration: #{video.dur.to_time_string}" : "<span class='run'> Recording!</span>"
    text = "<div id = 'vid_#{video.id}'class = 'video-block'>"
    text << "<span class='video-label'>#{video.title}</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
    text << "<span class='video-inf' id='vidinf-#{video.id}'>Recorded at: #{video.recorded_at.strftime("%H:%M:%S")}  &nbsp;&nbsp;#{running}&nbsp;&nbsp;&nbsp;&nbsp;</span>"
    text << "&nbsp;&nbsp;&nbsp;<span class = 'videoshow' id = 'vs-#{video.id}'>Hide</span>"
    text <<  display_video_menu(video)
    text
  end

def display_children(event,search = nil)
    text = ''
    if event.children.length > 0
      v = event.video
    event.children.each do |ss|
      extra_class = v && v.dur && ss.happened_at > v.happened_at + v.dur ? 'sm warning' : "sm sub-#{event.event_type}"
      text << "<div class = '#{extra_class}' id = 'event-#{ss.id.to_s}'>"
      text << '<span style = "font-weight:bold">'
      if v
        start_time = ss.happened_at - v.happened_at
        if event.video_viewable?
          text << put_see_video_link_around_time(event,start_time)
        else
          text << start_time.to_time_string
        end
      else
        text << '-'
      end
      text << '&nbsp;&nbsp;'
      ss.description ||= ''
      if search
        ss.title = highlight(ss.title,search,found_text_replacement_string)
        ss.description = highlight(ss.description,search,found_text_replacement_string)
      end
      text << "#{ss.title}"
      text << '</span><br />&nbsp;&nbsp;'
      text << ss.description
      text << display_menu_link(ss,'sevdm','small sevdm','span',false)
      text << '</div>'

    end
    end
    text
  end



end
#, onFailure:function(transport) {alert(“Error communicating with the server: ” + transport.responseText.stripTags());}
