# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
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
  def universal_table(items, options = {})
    confirmables = ['Destroy', 'Destroy All']
    return "<h2>No Items</h2>" if items.length < 1
    text = ''
    options[:actions] ||= [] #actions are links to actions in the same controller can also take a hash of {'action_description' => 'action_path'} if action name is destroy it will give you a confirm
    options[:admin] ||= {}
    options[:columns] ||= []
    show_form = options[:form] && options[:form][:show]
    order = params[:order] && params[:order] == 'asc' ? 'desc' : 'asc'
      
    text << put_search_field(options[:search_field])
    # Form Part
    if show_form
      text << options[:form]['form'] + "&nbsp;&nbsp;Check/Uncheck All: " + check_box_tag('hi',false,false,:class => 'check-all x')
    end
    # Start Table & Header Row
    text << "<table>\n<thead>\n<tr class = 'table-head'>\n"
    # Checkboxes
    text << "<th>\n#{options[:form]['label_for_checkboxes']}</th />\n" if show_form
    # Start Header Cells
    options[:columns].each do |column|
      sorter = column.delete(:sort)
      field_label = column.first[0]
      text << "<th>"
      if sorter #if it should sort on this column
        text << link_to(field_label,{:controller => params[:controller],:action => params[:action],:sort => sorter, :order => order})
      else
        text << field_label
      end
      text << "</th>\n"
    end
    
    if options[:actions].length > 0
      text << "<th colspan = '#{options[:actions].length.to_s}'>"
      text << "Actions"
      text << "</th>\n"
    end
    
    text << "</tr>\n" #end header row
    
    text << "</thead>\n<tbody>\n" #start body rows
    
    items.each do |item|
      text << "<tr class = \"#{cycle('row-1','row-2')}\">"
      if show_form
        text << "<td>"
        text << check_box_tag(options[:form]['label_for_checkboxes'],item.id,false,:class => 'check_all_able x')
        text << "</td>"
      end
      options[:columns].each do |column|
        sorter = column.delete(:sort)
        field_label = column.first[0]
        field_method = column.first[1]
        text << "<td>"
        if field_method[-3,3]=='_at'
          rec = recursive_send(item,field_method)
          text << rec.strftime("%Y-%d-%m - %H:%M %Z") if rec
        else
          addon = wrap_boolean(recursive_send(item,field_method).to_s)
          if options[:truncate]
            text <<  truncate(addon,:length => options[:truncate])
          else
            text <<  addon
          end
          
        end
        text << "</td>"
      end
      if !options[:actions].empty?
        options[:actions].each do |action|
          came_from = ''
          array = action.to_a.first
          action_label = array[0]
          if array[1][-1,1] == '$'
            came_from = came_from_string
            array[1].chop!
          end
          action_action = array[1]
          text << "<td>"
          
          if !options[:admin][action_label] ||  user_has_right?(options[:admin][action_label])
            text << "*" if options[:admin][action_label]
            
            confirm = confirmables.include?(action_label) ? 'Are You Sure?' : nil
            method = confirmables.include?(action_label) ? 'post' : 'get'
            text << link_to(action_label,"#{action_action}/#{item.id.to_s}#{came_from_string}",:method => method, :confirm => confirm )
          end
        end
          text << "</td>"
        
        
      end
      text << "<tr>\n"
    end
    text << "</tbody>\n</table>" #end body rows
    
    text << "</form>" if show_form
    text
  end


  def recursive_send(item,message)
    methods = message.split('.')
    methods.each do |method|
      return '<span style = "color:#a00">???</span>' unless item
      item = item.send(method)
      
    end
    item
  end
  def color_picker(model,attribute)
    # this works in conjunction with the javascript in application.js
    table = <<-END_OF_STRING
    <table id = 'colorpicker'>
        <tr>
        <td style="background:#e9f;"></td>
        <td style="background:#f4c;"></td>
        <td style="background:#a6f;"></td>
        <td style="background:#9c0;"></td>
        </tr>                       
        <tr>                        
        <td style="background:#66f;"></td>
        <td style="background:#6f6;"></td>
        <td style="background:#fa0;"></td>
        <td style="background:#33f;"></td>
        </tr>                       
        <tr>                        
        <td style="background:#c99;"></td>
        <td style="background:#9c9;"></td>
        <td style="background:#6cc;"></td>
        <td style="background:#fc3;"></td>
        </tr>                       
        <tr>                        
        <td style="background:#ccc;"></td>
        <td style="background:#a6f;"></td>
        <td style="background:#9c0;"></td>
        <td style="background:#777;"></td>    
        </tr>
    </table>
    END_OF_STRING
    colorstring = eval("#{model}.#{attribute}")
    text = "&nbsp;Color:<div id='color-display' style='background:##{colorstring}'></div>"
    text << text_field_tag(attribute, colorstring, :size => 6, :id => 'div_class')
    text << '<br />'
    text << table
  end

  def checklist(model,collection,fields,checked_collection=[],checked_field=nil,show_check_all = true,reset_number = 8)
    #this works in conjunction with the javascript in application.js
    checked_ids = checked_field ? checked_collection.map{|x| eval("x.#{checked_field}")} : checked_collection
    text = "<div id = '#{model}'>"
    counter = 1
    if fields.length == 2
      full_list = collection.collect {|x| {fields[0] => eval("x.#{fields[0]}") ||'',fields[1] => eval("x.#{fields[1]}")||''}}.sort_by {|x| x['short_name']}
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

  def put_menu
    text = "<ul id = \"capmenlsr\">"
    text << "<li><a class=\"mened\" href=\"/capture/mod_ev/\">Edit</a></li>"
    text << "<li><a class=\"mendel\" href=\"/capture/delete_event/\">Delete</a></li>"
    text << "<li><a class=\"mened\" href=\"/capture/new_note/\">New Note</a></li>"
    text << "</ul>"
    text << "<ul id = \"capmenlss\">"
    if user_has_right?('highlight')
      text << "<li><a class=\"menhi\" href=\"/capture/toggle_highlight/\">Highlight ON/OFF</a></li>"
    end
    if true
      text << "<li><a class=\"menhi\" href=\"/capture/toggle_user_highlight/\">Personal Mark On/Off</a></li>"
      text << "<li><a class=\"menhi\" href=\"/capture/rate/0/\">Rate 0</a> <a class=\"menhi\" href=\"/capture/rate/1/\">1</a> <a class=\"menhi\" href=\"/capture/rate/2/\">2</a> <a class=\"menhi\" href=\"/capture/rate/3/\">3</a> <a class=\"menhi\" href=\"/capture/rate/4/\">4</a> <a class=\"menhi\" href=\"/capture/rate/5/\">5</a></li>"
      text << "<li><a class=\"menhi\" href=\"/capture/tag_with_title/\">Tag With Title</a></li>"
    end
    if user_has_right?('advanced_actions')
      text << "<li><a class=\"mened\" href=\"/capture/new_event/scene?after=\">Insert Event After</a></li>"
      text << "<li><a class=\"menhisub\" href=\"/capture/convert_to_sub_scene/\">Convert to Subscene</a></li>"
      text << "<li><a class=\"mened\" href=\"/capture/move_event/\">Move Event</a></li>"
    end
    text << "</ul>"
  end


  def put_v_menu
    text = "<ul id = \"vidmenlist\">"
    text << "<li><a class=\"menhi\" href=\"/capture/rate_video/0/\">Rate 0</a> <a class=\"menhi\" href=\"/capture/rate_video/1/\">1</a> <a class=\"menhi\" href=\"/capture/rate_video/2/\">2</a> <a class=\"menhi\" href=\"/capture/rate_video/3/\">3</a> <a class=\"menhi\" href=\"/capture/rate_video/4/\">4</a> <a class=\"menhi\" href=\"/capture/rate_video/5/\">5</a></li>"
    text << "<li><a class=\"mened\" href=\"/capture/add_event_to_video/\">Add Event</a></li>"
    text << "</ul>"
  end
  def put_viewer_menu
    text = "<ul id = \"eviewlist\">"
    text << "<li><a class = 'get pause' href='/events/edit_annotation/'>Edit</a></li>"
    text << "<li><a class=\"menhi\" href=\"/events/rate/0/\">Rate 0</a> <a class=\"menhi\" href=\"/events/rate/1/\">1</a> <a class=\"menhi\" href=\"/events/rate/2/\">2</a> <a class=\"menhi\" href=\"/events/rate/3/\">3</a> <a class=\"menhi\" href=\"/events/rate/4/\">4</a> <a class=\"menhi\" href=\"/events/rate/5/\">5</a></li>"
    text << "</ul>"
  end
  def put_viewer_sub_menu
    text = "<ul id = \"viewsubmenlist\">"
    text << "<li><a class='get pause' href='/sub_scene/edit_sub_annotation/' >Edit</a></li>"
    text << "</ul>"
  end
  def put_s_menu
    text = "<ul id = \"submenlist\">"
    text << "<li><a class=\"mened\" href=\"/capture/edit_sub_scene/\">Edit</a></li>"
    text << "<li><a class=\"mendelsub\" href=\"/capture/delete_sub_scene/\">Delete</a></li>"
    text << "<li><a class=\"mensubpr\" href=\"/capture/promote_to_scene/\">Promote</a></li>"
    text << "</ul>"
  end

  def menu_first_level(title, &block)
  content = capture(&block)
  concat(menu_open_first_level(title))
  concat(content)
  concat(menu_close_first_level)
  end
  
  def menu_open_first_level(title)
    html = "<li><a>" + title + '</a>' + "<ul>\n"#opens list of menu items
  end
  def menu_close_first_level
    html = "</ul></li>\n"
  end
  
  def menu_second_level(tip, title, &block)
  content = capture(&block)
  concat(menu_open_second_level(tip, title))
  concat(content)
  concat(menu_close_second_level)
  end

  def menu_open_second_level(tip, title)
    html = "<li><a class='drop' href='#' title='" + tip + "'>" + title + "</a>\n"
    html << "<ul class = 'right'>\n" #opens second level list
  end
  def menu_close_second_level
    html =  "</ul>\n</li>"
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
  def display_menu_link(item,css_class,size = '',tag = 'div', rate = false)
    return '' unless user_has_right?('normal_actions')
    text = "<#{tag} class = 'men #{css_class} #{size}' id = 'm-#{item.id}'>"
    text << ' <a href="" data-action="alert">MENU...</a>'
    text << display_rating(item) if rate
    text << "</#{tag}>"
  end
  def display_video_menu(video)
    #display_menu_link(video,'men vvim')
    text = "<div class='men vvim'id='m-#{video.id}'>"
    #text << 'hi'
    video.rating.times do
      text << '<span>* </span>'
    end
    text << ' <a href=''>MENU...</a>'
    text << "</div>"
    text
  end
  
  def display_viewer_subsc_menu(sub_scene)
    if user_has_right?('normal_actions')
    text = "<span class='men summ viewersmen small' id='s-#{sub_scene.id}'>"
    text << "<a href=''>MENU...</a>"
    text << "</span>"
    else
      ''
    end
  end
  
  def piece_select_with_none
    start = [['None', '']]
    start += current_configuration.pieces.map{|x| [x.title,x.id]}
  end
  def put_location_select(selected=nil)
    selected ||= current_configuration.location.location
    locations = [['none','none']]
    locations += Location.all.map{|x| [x.location,x.location]}
    locations_options = options_for_select(locations,selected)
    select_tag('location',locations_options)
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
      out << '<script type="text/javascript" src="/javascripts/s3_upload.js"></script>' 
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
   videos += current_piece.recordings.map{|x| [x.title,x.title]}
  end
 
  def options_for_video_search
    options = "<option value='no_dvd'>No Video</option>"
    options += options_from_collection_for_select(current_piece.recordings, "id", "title")
  end
  def events_performers(event)
    events_performers = event.performers[0] == 'Everyone' ? current_piece.performers.map{|x| x.short_name}.sort : event.performers
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
      text = event.title ? highlight(sanitize(event.title), search, SetupConfiguration.found_text_replacement_string) : ''
      text << " (#{event.piece.title})" if @show_piece
      text
    end
  end
  #class="go_to" id="go-6363"
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
        text << SetupConfiguration.no_video_string
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
    info = "<div class='sm evci'>"
      info << event.happened_at.strftime("%d/%m %H:%M:%S") +' by ' + event.created_by + ' ' + linked_id(event)

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
  def more_string(event)
    length = event.description.length - SetupConfiguration.truncate_length
    string = '&nbsp;&nbsp;<a class = "more" href="'
    string << "#{event.id}"
    string << '">'+length.to_s+' More</a>'
  end
  def less_string(event)
    string = '&nbsp;&nbsp;<a class = "less" href="'
    string << "#{event.id}"
    string << '">Less...</a>'
  end

  def display_description(event,search = nil)
    if (event.description)
      text = "<div class='sm evdes'>"
      
      tt = case @truncate
        when :more then my_tags(truncate(event.description,:length => SetupConfiguration.truncate_length, :omission => more_string(event)))
        when :less then event.description.length > SetupConfiguration.truncate_length ? my_tags(event.description) + less_string(event) : my_tags(event.description)
        else  my_tags(event.description)
        end
      if search
        tt = highlight(tt,search,SetupConfiguration.found_text_replacement_string)
      end
      text << tt
      text << '</div>'
    else
      text = ''
    end
  end
  def display_subscenes(event,search = nil)
    text = ''
    if event.sub_scenes.length > 0
      v = event.video
    event.sub_scenes.each do |ss|
      extra_class = v && v.duration && ss.happened_at > v.recorded_at + v.duration ? 'sm warning' : "sm sub-#{event.event_type}"
      text << "<div class = '#{extra_class}' id = 'sus-#{ss.id.to_s}'>"
      text << '<span style = "font-weight:bold">'
      if v
        start_time = ss.happened_at - v.recorded_at
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
        ss.title = highlight(ss.title,search,SetupConfiguration.found_text_replacement_string)
        ss.description = highlight(ss.description,search,SetupConfiguration.found_text_replacement_string)
      end
      text << "#{ss.title}"
      text << '</span><br />&nbsp;&nbsp;'
      text << ss.description
      text << display_menu_link(ss,'summ','small','span',false)
      text << '</div>'
      
    end
    end
    text
  end

  
  def display_performers(event,search = nil)
    if event.performers
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
        string << ' <a style = "background:none;color:#fff;" href ="/capture/present?filter_type=tag&taggs='+tag.name+'">'+tag.name+'</a>'
        if index < non_title_tags.length-1
          string << ','
        end
      end
    string << '</div>'
    end    
  end
  
  def put_undelete_link(event)
   "<a class='dg'id= '#{event.id}'href='/capture/undelete_event/#{event.id}'>Undelete</a>&nbsp;<a class='dgdele'id= '#{event.id}'href='/capture/destroy_event/#{event.id}'>Destroy Forever</a>&nbsp;"  
  end
  
  
  def display_note_creation_info(event)
    info = event.created_at.strftime("%d/%m - %H:%M") +' by ' + event.created_by
  end
  def display_whole_note(note)
    text = ''
    text << note.note + '&nbsp;&nbsp;--'
    text << "<span class = 'noteinfo'>#{note.created_by} @ #{note.created_at.strftime("%d/%m - %H:%M")}:</span>&nbsp;&nbsp;"
    
    text << display_note_edit_links(note)
    text
  end
  def display_note_edit_links(note)
    note_edit_link = ''
    if note.created_by == current_user.login || user_has_right?('advanced_actions')
      
      note_edit_link << "<a class='dged' href='/capture/edit_note/#{note.id}'ajt='#note_note#{note.id}'>Edit</a>&nbsp;"
      note_edit_link << "<a class='dgdeln'id='n-#{note.id}' href='/capture/delete_note/#{note.id}'>Delete</a>&nbsp;"
      #note_edit_link << "<a class='dged''href='/capture/new_photo/#{note.id}'>Photo</a>"
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
      text << '<span class="short-cut">I </span><a id = "vidinout" class = "get hdble vout" href = "/capture/confirm_video_io/'+vvid+'">Stop Video</a>'
      if current_configuration.use_auto_video
        text << '<br/><span class="short-cut">R </span><a id = "vidreload" class = "dga hdble vrel" href = "/capture/reload_video/'+vvid+'">Reload Video</a>'
      end
    else
      text << '<span class="short-cut">I </span><a id = "vidinout" class = "get hdble vprep" href = "/capture/new_auto_video_in">Prepare Video</a>'
      text << '<br /><span class="short-cut">B </span><a id = "vidinout" class = "get hdble vprep" href = "/capture/new_auto_video_in?quick_take=true">Prep. Vid & Scene</a>'
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
  
  def put_date(date,i,location = nil)
    location ||=''
    '<div id = "dat-'+i.to_s+'" style = "color:#d00;font-size:20px;margin-left:-25px">' + date.strftime("%A %d %b %Y")+'&nbsp;&nbsp;&nbsp;'+location +'</div>'
  end

  def open_video_html(video)
    running = video.duration ? "Duration: #{video.duration.to_time_string}" : "<span class='run'> Recording!</span>"
    text = "<div id = 'vid_#{video.id}'class = 'video-block'>"
    text << "<span class='video-label'>#{video.title}</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
    text << "<span class='video-inf' id='vidinf-#{video.id}'>Recorded at: #{video.recorded_at.strftime("%H:%M:%S")}  &nbsp;&nbsp;#{running}&nbsp;&nbsp;&nbsp;&nbsp;#{video.events.length} Event#{video.events.length == 1 ? '' : 's'}</span>"
    text << "&nbsp;&nbsp;&nbsp;<span class = 'videoshow' id = 'vs-#{video.id}'>Hide</span>"
    text <<  display_video_menu(video)
    text
  end
  
end
#, onFailure:function(transport) {alert(“Error communicating with the server: ” + transport.responseText.stripTags());}
