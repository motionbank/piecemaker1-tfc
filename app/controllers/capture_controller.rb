class CaptureController < ApplicationController
  layout 'standard', :except => [:do_present, :cheap_rtf]
  #
  # present makes the main page
  #
  before_filter :get_event_from_params, :only => [:rate, :delete_event, :undelete_event, :destroy_event, :move_event, :unlock, :tag_with_title, :more_description, :less_description, :do_move,:toggle_user_highlight]
  
  def get_event_from_params
    @event = Event.find(params[:id])
  end

  def search_by_performer
    params[:performer_filter] = 'true'
    respond_to do |format|
      format.html
      format.js {render :action => 'search_by_performer',:layout => false} 
    end
  end
  def search_by_tag
    respond_to do |format|
      format.html
      format.js {render :action => 'search_by_tag',:layout => false} 
    end
  end
  def search_by_text
    respond_to do |format|
      format.html
      format.js {render :action => 'search_by_text',:layout => false} 
    end
  end
  def search_by_video
    respond_to do |format|
      format.html
      format.js {render :action => 'search_by_video',:layout => false} 
    end
  end  
  def date_range
    respond_to do |format|
      format.html
      format.js {render :action => 'date_range',:layout => false} 
    end
  end

  def performer_names_from_params
    params[:search_ids] ||= []
    filterpeople = params[:search_ids].map{|x| x.downcase}.sort
  end
  def filter_type
    @filter_type = params[:filter_type] || 'none'
  end
  
  def present
    if(params[:id])
      session[:pieceid] = params[:id]
    end
    if(current_piece)
        @title = 'Capture: '+current_piece.title
        do_present
        respond_to do |wants|
          wants.html {  }
        end
    else
      flash[:notice] = "I couldn't find this piece!"
      redirect_to  pieces_url
    end
  end
  
  def get_events(piece_id = session[:pieceid])
    conditions = "(piece_id = #{piece_id}) AND (state = 'normal' OR state = 'uploaded')"
    conditions += "AND (event_type != 'dev_notes') " unless user_has_right?('view_dev_notes')
    conditions += "AND (event_type != 'marker')" unless current_user.markers_on
    conditions += "AND (parent_id is NULL )"
    Event.where(conditions).order('happened_at').includes([:video,:tags,:users,:children,:notes])#.includes([{:video => :events},:sub_scenes,:tags,:notes,:users])
  end

  def do_present
    hide_trash = true
    @terms = []
    @total_event_number = current_piece.events.size
    @refresh = 'Never' unless ['none','today_only'].include?(filter_type)
    case filter_type
      when 'user_highlighted'
        @events = current_user.events.in_piece(current_piece.id)
      when 'span'
        span_count = params[:span_count] ? params[:span_count].to_i : 50
        @events = Event.order('happened_at DESC').limit(span_count)
        @show_piece = true
      when 'one_event'
        @events = [Event.find(params[:event])]
      when 'date_range'
        flash.now[:searched_for] = "Events between #{dater(params[:start_date])} and #{dater(params[:end_date])}"
        @events = current_piece.events.normal.within_date_range(params[:start_date],params[:end_date]).sort_by{|x| x.happened_at}
      when 'today_only'
        flash.now[:searched_for] = "Today's Events"
        @events = current_piece.events.normal.created_today.sort_by{|x| x.happened_at}
      when 'performer'
        @total_cast_number = current_piece.performers.length
        events = get_events
        events = performer_filter(events)
        @events = events.sort_by{|x| x.happened_at}
      when 'highlighted'
        flash.now[:searched_for] = "Highlighted Events"
        @events = current_piece.events.normal.highlighted
      when 'tag'
        @events = Tag.find_by_name(params[:taggs]).events.normal
        flash.now[:searched_for] = "Events with Tag: #{params[:taggs]}"
      when 'video'
        video_id = params[:video] == 'no_dvd' ? nil : params[:video].to_i        
        @events = current_piece.events.normal.in_video(video_id)
        flash.now[:searched_for] = params[:video] == 'no_dvd' ? "Events without video" : "Events in video id: #{params[:video]}"
      
      when 'text'
        events = current_piece.events.normal.contains(params[:search])#nd_with_index('my search query')
        # subscenes = current_piece.events.normal.select{|x| !x.sub_scenes.contains(params[:search]).empty? }.flatten
        # events += subscenes
        # events.uniq!
        flash.now[:searched_for] = "Search Results for : \"#{params[:search]}\""

        @terms = [params[:search]]
        @events = events
        @truncate = :none
      when 'trash'
        hide_trash = false
        @events = current_piece.events.select{|x| x.is_deleted?}
      when 'rating'
        @events = Event.where("piece_id = ? AND (state = 'normal') AND (rating > ?)",session[:pieceid],params[:rating].to_i).order('happened_at').includes([:video,:sub_scenes,:tags,:notes])
      when 'tail'
        @events = Event.where("piece_id = ? AND (state = 'normal')",session[:pieceid]).order('happened_at DESC').includes([:video,:sub_scenes,:tags,:notes]).limit(100)
        vids = @events.map{|x| x.video}.uniq.compact
      when  'none'
        @events = get_events
        @refresh = 'Never' if (@total_event_number > 99 )
    end
     @event_count = @events.length
  end

  def dater(string)
    string.split(' ').first.split('-').reverse.join('/')
  end
  def toggle_user_highlight #OK
    @event.toggle_user_highlight(current_user)
    respond_to do |format|
      format.html { redirect_to :action => "present", :id => session[:pieceid] }
      format.js {render :action => 'modi_ev', :layout => false} 
    end
  end
  def rate #OK
    @event.rating = params[:rating].to_i
    @event.save
    respond_to do |format|
      format.html { redirect_to :action => "present", :id => session[:pieceid] }
      format.js {render :action => 'modi_ev', :layout => false} 
    end
  end
  def rate_video #OK
    @video = Event.find(params[:id])
    @video.rating = params[:rating].to_i
    @video.save
    respond_to do |format|
      format.html { redirect_to :action => "present", :id => session[:pieceid] }
      format.js {render :action => 'rate_video', :layout => false} 
    end
  end
  def add_event_to_video
    @create = true
    @video = Event.find(params[:id])
    @event = @video.subjects.create(
    :happened_at => @video.happened_at + 2,
    :created_by => current_user.login,
    :modified_by => current_user.login,
    :performers => [],
    :event_type => 'scene',
    :piece_id => session[:pieceid])
    respond_to do |format|
      format.html { redirect_to :action => "present", :id => session[:pieceid] }
      format.js {render :partial => 'event_form', :layout => false} 
    end
  end

 def update_vid_time
    videos = Piece.find(session[:pieceid]).videos
    text = 'Video: '
   if videos.length > 0
     if videos.last.dur && videos.last.recorded_at + videos.last.dur < Time.now
       text << 'none'
     else
       time = Time.now.to_i - videos.last.recorded_at.to_i
       text << videos.last.title + '&nbsp;&nbsp;'+ time.to_time_string
     end
   else
     text << 'none'
   end
   text << ' Click to Update'
   render :text => text
 end
 
 def fill_video_menu
   video = Event.find(params[:id])
   text = ''
   if true#video.viewable?
     text << "<li class = 'removable'><a class = 'ignore' href = '/video_viewer/#{params[:pieceid]}/#{params[:id]}'>Watch in Viewer</a></li>"
   else
     text << "<li style = 'color:#ccc' class = 'removable'>Video Not Viewable.</li>"
   end
   text << "<li class = 'removable'><a class = 'ignore' href = '/video_upload/#{params[:id]}/#{params[:pieceid]}'>Upload</a></li>"
     render :text => text
 end
 #
 # methods for creating, editing and deleting notes and photo attachments
 #
  def new_note #OK
    if request.post?
      @event = Event.find(params[:id]) # this is needed to display the event after the note is created
      @note = Event.new(params[:note])
      @note.parent_id = params[:id].to_i
      @note.piece_id = @event.piece_id
      @note.modified_by = current_user.login
      @note.happened_at = Time.now
      @note.event_type = 'note'
      @note.title = 'Note'
      @note.performers = []
      @note.created_by = current_user.login
      if @note.save
        respond_to do |format|
          format.html {redirect_to :action => 'present'}
          format.js {render :action => 'new_note', :layout => false} 
        end
      else
        render :controller => 'capture', :action => 'new_note'
      end
    else
      @note = Event.new
      respond_to do |format|
        format.html { render :partial => 'note_form', :layout => 'standard'}
        format.js {render :partial => 'note_form', :layout => false} 
      end
    end
  end


  def edit_note #OK
    if request.post?
      @note    = Event.find(params[:id])
      @note.description = params[:notes][:description]
      @note.save
      respond_to do |format|
        format.html {redirect_to :action => 'present'}
        format.js {render :action => 'edit_note', :layout => false} 
      end
    else
      @note = Event.find(params[:id])
      respond_to do |format|
        format.html { render :partial => 'note_edit_form', :layout => 'standard'}
        format.js {render :partial => 'note_edit_form', :layout => false} 
      end
    end
  end

  def delete_note #OK
    @note = Event.find(params[:id])
    if request.post?
      @note.destroy
      respond_to do |format|
        format.html {redirect_to :action => 'present'}
        format.js {render :text => "#{@note.id}" }
      end
    else
      #renders the confirmation page 'delete_note.rhtml'
    end
  end


 #
 # methods for creating editing and deleting events
 #

  def delete_event
    if request.post?
      @event.make_deleted
      @event.save
      respond_to do |format|
        format.html {redirect_to :action => 'present'}
        format.js {render :text => "", :layout => false} 
      end
    end
  end
  def undelete_event
      @event.make_undeleted
      @event.save
      respond_to do |format|
        format.html {redirect_to :action => 'present'}
        format.js {render :partial => 'undelete_event', :layout => false} 
      end
  end
  def destroy_event
    if request.post?
      @event.destroy
      respond_to do |format|
        format.html {redirect_to :action => 'present'}
        format.js {render :text => "", :layout => false} 
      end
    end
  end
  def quick_marker #from iphone
    @piece = Piece.find(params[:id])
    if request.post?
      event = Event.new(
      :happened_at => Time.now,
      :created_by => current_user.login,
      :event_type => 'marker',
      :piece_id => params[:id],
      :state => 'normal',
      :title => 'marker'
      )
      event.set_video_time_info
      event.save
      flash[:notice] = 'Added Marker at ' + event.happened_at.strftime("%H:%M:%S")
    end
    respond_to do |format|
      format.html {}
      format.mobile {}
      format.js {render :layout => false}
    end
  end

  def marker_list
    @piece = Piece.find(params[:id])
    @markers = Event.find_all_by_piece_id(@piece.id,
    :conditions => "event_type = 'marker' AND created_by = '#{current_user.login}'",
    :order => 'happened_at DESC')
    render :layout => 'marker'
  end
  def mark_from_marker_list
    #@piece = Piece.find(params[:id])
    #if request.post?
    @event = Event.new(
      :happened_at => Time.now,
      :created_by => params[:user].gsub('.js',''),
      :event_type => 'marker',
      :piece_id => params[:id],
      :state => 'normal',
      :title => 'marker'
    )
    @event.save
    #end
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  def delete_marker_from_list
    marker = Event.find(params[:id])
    @marker_id = marker.id
    marker.destroy
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  def new_marker
    @create = true
    @event = Event.new
    @after_event = @event.set_attributes_from_params(params,current_user,current_piece)
    @event.event_type = 'marker'
    @event.title = 'marker'
    @event.state = 'normal'
    @event.performers = nil
    @event.save
    respond_to do |format|
      format.html {render :action => 'event_form'}
      format.js {render :action => 'modi_ev',:layout => false} 
    end
  end
  def new_event
    #@events = Event.find_all_by_piece_id(session[:pieceid], :order => 'position')
    @create = true
    @event = Event.new
    @after_event = @event.set_attributes_from_params(params,current_user,current_piece)
    respond_to do |format|
      format.html {render :action => 'event_form'}
      format.js {render :partial => 'event_form',:layout => false} 
    end
  end
  def new_sub_scene #OK
    @create_scene = false
    @action = 'create_sub_scene'
    piece = Piece.find(session[:pieceid])
    @latest_event = piece.root_events.normal.last

    if @latest_event
      if (@latest_event.video && @latest_event.video.dur && Time.now > @latest_event.video.recorded_at + @latest_event.video.duration) || !@latest_event.video && video_in?
        @create_scene = true
      end
      @sub_scene = Event.new(
      :happened_at => Time.now + 1)
      respond_to do |format|
        format.html {render :action => 'new_sub_scene'}
        format.js {render :action => 'new_sub_scene',:layout => false} 
      end
    else
      respond_to do |format|
        format.html {redirect_to :action => 'present', :id => session[:pieceid]}
        format.js {render :action => 'empty_sub_scene',:layout => false} 
      end
    end
  end
  def create_sub_scene#OK except for parse performers....
    @event = Event.find(params[:sub_scene][:parent_id])
    if params[:create_scene] == 'true'
      @new_event = @event.dup
      @new_event.title << ' ...Continued...'
      @new_event.video_id = video_in? ? video_in?.id : nil
      @new_event.happened_at = Time.now
      @new_event.save
      params[:sub_scene][:parent_id] = @new_event.id
      @event = @new_event
      @create = true
    end
    sub_scene = Event.create(params[:sub_scene])
    sub_scene.performers = []
    sub_scene.save
    #sub_scene.parse_performers_and_give_to_parent
    respond_to do |format|
      format.html { redirect_to :controller => 'capture', :action => "present", :id => session[:pieceid] }
      format.js {render :action => 'modi_ev', :layout => false} 
    end
  end
  def edit_sub_scene #OK
    @action = 'update_sub_scene'
    @sub_scene = Event.find(params[:id])
    @latest_event = @sub_scene.parent
    respond_to do |format|
      format.html {render :action => 'new_sub_scene'}
      format.js {render :action => 'new_sub_scene',:layout => false} 
    end
  end
  def update_sub_scene #OK
    sub = Event.find(params[:id])
    sub.update_attributes(params[:sub_scene])
    #sub.parse_performers_and_give_to_parent
    @event = sub.parent
    respond_to do |format|
      format.html { redirect_to :controller => 'capture', :action => "present", :id => session[:pieceid] }
      format.js {render :action => 'modi_ev', :layout => false} 
    end
  end
  def delete_sub_scene #OK
    sub = Event.find(params[:id])
    id = sub.parent_id
    @event = Event.find(id)
    sub.destroy
    respond_to do |format|
      format.html { redirect_to :controller => 'capture', :action => "present", :id => session[:pieceid] }
      format.js {render :text => "#{sub.id}", :layout => false} 
    end
  end
  def cancel_new_ev
    if @event = Event.find_by_id(params[:id])
      @event.make_deleted
    end
    respond_to do |format|
      format.html {redirect_to :action => 'present', :id => @event.piece_id }
      format.js {render :action => 'cancel_new_ev',:layout => false} 
    end
  end
  def cancel_new_vid
    #video = Video.find(params[:id])
    #current_piece.recordings.delete(video)
    #video.destroy
    render :text => '$("#form_div").hide();$("#form_div").html('');
    $(".hdble").show();'
  end


  def mod_ev
    #puts up the modify form
    @viewer = params[:viewer] && params[:viewer] == 'true.js' ? true : false
    @event = Event.find(params[:id]) 
    if(@event.locked_by)
      partial_name = 'locked'
      @unlock = true
    else
      @event.lock(current_user.login)
      @event.save
      partial_name = 'event_form'
    end
    respond_to do |format|
      format.html
      format.js {render :partial => partial_name, :layout => false} 
    end
  end

  def move_event
    respond_to do |format|
      format.html
      format.js {render  :layout => false} 
    end
  end

  def do_move
    @event = Event.find(params[:id])

      if new_e = Event.find_by_id(params[:after].to_i)
        if new_e.piece_id == @event.piece_id
          @event.happened_at = new_e.happened_at + 1
          @event.save
          @event.set_video_time_info
          @event.save
          flash[:notice] = "Event id: #{@event.id} moved"
        end      
      else
        flash[:notice] = "Target event: #{params[:after]} doesn't exist! Please choose move destination carefully."
      end
    redirect_to :action => 'present', :id => session[:pieceid] 
  end

  def unlock
    @event.unlock
    @event.save
    @unlock = true;
    respond_to do |format|
      format.html { redirect_to :controller => 'capture', :action => "present", :id => session[:pieceid] }
      format.js {render :partial => 'event_form', :layout => false} 
    end
  end


  def new_auto_video_in
    @text = "Start"
    @player = true
    @dvd_quick = 'out'
    if video_in?
      respond_to do |format|
        format.html {redirect_to :action => 'present', :id => session[:pieceid]}
        format.js {render :partial => 'warn_prepare', :layout => false} 
      end
    else
      piece = Piece.find(session[:pieceid])
      @create = true
      @video = Event.new  
      @video.set_video_title(piece)
      Video.prepare_recording() if true
      respond_to do |format|
        format.html
        format.js {render :partial => 'new_auto_video', :layout => false} 
      end
    end
  end

  def confirm_video_in
    @after_id = params[:aid] #needed to tell jquery where to insert event
    @create = true if params[:create] == 'true'
    @video = Event.new(params[:video])
    @video.happened_at = Time.now
    @video.created_by = current_user.login
    @video.modified_by = current_user.login
    @video.event_type = 'video'
    @video.performers = []
    @video.save
    if params[:quick_take] && params[:quick_take] == 'true'
      Event.create(
        :piece_id => current_piece.id,
        :video_id => @video.id,
        :performers => [],
        :event_type => 'performance_notes',
        :title => "Performance of #{current_piece.title}",
        :created_by => current_user.login,
        :modified_by => current_user.login,
        :happened_at => Time.now + 1,
        :state => 'normal',
        :description => ''
        )
    end
    current_piece.events << @video
    @dvd_quick = 'out'
    @truncate = :less unless @truncate == :none
    result = Video.start_recording() if SetupConfiguration.use_auto_video?

    respond_to do |format|
      format.html {redirect_to :action => 'present', :id => session[:pieceid] }
      format.js {render :action => 'confirm_video_in', :layout => false}
    end
  end
  def confirm_video_out
    @after_id = params[:aid] #needed to tell jquery where to insert event
    @create = true if params[:create] == 'true'
    @video = Event.find_by_id(params[:id])
    @dvd_quick = 'insert'
    @video.dur = Time.now - @video.happened_at
    @video.save
    @truncate = :less unless @truncate == :none
    result = Video.stop_recording(@video.title) if SetupConfiguration.use_auto_video?
    
    flash[:notice] = 'result'
      if result && result != 'error'
        #@video.rename_quicktime_and_queue_processing(result)
        @flash_message = "#{result} stored as #{@video.title}"
      else
        @flash_message = "Couldn't store #{result}"
      end

    respond_to do |format|
      format.html {redirect_to :action => 'present', :id => session[:pieceid] }
      format.js {render :action => 'confirm_video_out', :layout => false}
    end
  end
  
  def modi_ev #OK
    #actually changes the event and saves it
      @after_id = params[:aid] #needed to tell jquery where to insert event
      @create = true if params[:create] == 'true'
      @event = Event.find(params[:id]).do_event_changes(params,current_user)
      @event.state = 'normal' if @create #is this necessarey anymore?
      if @event.save
        @dvd_quick = video_in? ? '' : 'insert' 
        @flash_message = "Successfully #{@create ? 'created': 'edited'} event id: #{@event.id}"
        @truncate = :less unless @truncate == :none
        respond_to do |format|
          format.html {redirect_to :action => 'present', :id => @event.piece_id }
          format.js {render :action => 'modi_ev', :layout => false}
        end
      else
        render :action => 'event_form'
      end
  end
    
  def tag_with_title #???
    @event.tag_with_title
    respond_to do |format|
      format.html {redirect_to :action => "present", :id => session[:pieceid] }
      format.js {render :action => 'modi_ev', :layout => false} 
    end
  end

  def cancel_modify #OK
    @event = Event.find(params[:id])
    @event.unlock
    @event.save
    respond_to do |format|
      format.html {redirect_to :action => 'present', :id => @event.piece_id }
      format.js {render :action => 'modi_ev', :layout => false}
    end
  end

 def toggle_highlight #OK
   @event = Event.find(params[:id]).toggle_highlight!
   respond_to do |format|
     format.html { redirect_to :action => "present", :id => session[:pieceid] }
     format.js {render :action => 'modi_ev', :layout => false} 
   end
 end

 def create_video #???
   if @video = Video.find(params[:id])
     @video.update_from_params(params)
   end
   redirect_to  :action => 'present', :id => params[:piece_id]
 end

  def search_type #OK
    if params[:yes]
      return 'exclusive'
    end
    if params[:semi]
      return 'semi_exclusive'
    end
    if params[:everyone]
      return 'everyone'
    end
    if params[:non_with_everyone]
      return 'non_with_everyone'
    end
    if params[:no]
      return 'non_exclusive'
    end
  end
  def performer_filter(events) #OK
    name_list = performer_names_from_params.join(' ')
    if performer_names_from_params.length == 0 && search_type != 'everyone'
      return []
    end
    
    case search_type #OK
      when 'exclusive' #exactly the searched for people and no others
        flash.now[:searched_for] = "Exclusive Search for : \"#{name_list}\""
        batch = events.select{|x| x.performer_exclusive?(performer_names_from_params)}
      when 'semi_exclusive'
        flash.now[:searched_for] = "Semi-Exclusive Search for : \"#{name_list}\""
        batch = events.select{|x| x.performer_semi_exclusive?(performer_names_from_params)}
      when 'everyone'
        flash.now[:searched_for] = "Search for : Everyone"
        batch = events.select{|x| x.performer_everyone?}
      when  'non_with_everyone'
        flash.now[:searched_for] = "Non-Exclusive Search for : \"#{name_list}\" and Everyone"
        batch = events.select{|x| x.performer_non_exclusive_with_everyone?(performer_names_from_params)}
      else #returns all events where the person appears except for events with "everone"
        flash.now[:searched_for] = "Non-Exclusive Search for : \"#{name_list}\""
        batch = events.select{|x| x.performer_non_exclusive?(performer_names_from_params)}
      end
  end


    def more_description #OK
      set_current_piece(@event.piece_id)
      @truncate = :less
      respond_to do |format|
        format.html {redirect_to :action => 'present', :id => @event.piece_id }
        format.js {render :partial => 'one_event', :locals => {:event => @event}, :layout => false}
      end
    end
    def less_description #OK
      set_current_piece(@event.piece_id)
      @truncate = :more
      respond_to do |format|
        format.html {redirect_to :action => 'present', :id => @event.piece_id }
        format.js {render :partial => 'one_event', :locals => {:event => @event}, :layout => false}
      end
    end

    def cheap_rtf
      @events = Event.where("pieceid = ?", session[:pieceid]).order('happened_at')
    end

    def open_scratchpad #OK
      @pad = current_user.scratchpad
      respond_to do |format|
        format.html
        format.js {render :action => 'open_scratchpad', :layout => false} 
      end
    end
    def update_scratchpad #OK
      current_user.scratchpad = params[:scratchpad]
      current_user.save
      respond_to do |format|
        format.html
        format.js {render :text => "$('#scratchpad').hide();$('.formhide').show();"} 
      end
    end
    def promote_to_scene #OK
      ss = Event.find(params[:id])
      oldid = ss.parent_id
      @new_event = ss.promote_to_scene
      @event = Event.find(oldid)
    end

    def convert_to_sub_scene #OK
      event = Event.find(params[:id])
      ss = event.demote_to_sub_scene
      if ss
        @event = ss.parent
      end
      respond_to do |format|
        format.html {redirect_to :action => 'present', :id => current_piece.id}
        format.js {render :action => 'convert_to_sub_scene', :layout => false} 
      end
    end
# from subscene controller
  #   def move_from_viewer
  #   @sub_scene = SubScene.find(params[:id])
  #   time = params[:time].gsub('.js','')
  #   @sub_scene.happened_at = @sub_scene.event.video.recorded_at + time.to_i
  #   @sub_scene.save
  #   #@sub_scene.check_for_reposition
  #   @video = @sub_scene.event.video
  #   respond_to do |format|
  #     format.html
  #     format.js {render :controller => 'events', :action => 'move_from_viewer'}
  #   end
  # end
  # def edit_sub_annotation
  #   @sub_scene = SubScene.find(params[:id])
  #   respond_to do |format|
  #     format.html
  #     format.js {render :layout => false}
  #   end
  # end

end

