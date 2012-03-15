class EventsController < ApplicationController
  layout 'standard', :except => 'unlock'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #          :redirect_to => { :action => :list }
  
  def capture
    @events = Event.find_all_by_piece_id(params[:id],:order => :happened_at)
  end

  def add_sub_annotation
    @video = Video.find(params[:id])
    set_current_piece(params[:piece_id].gsub('.js','').to_i)
    time = params[:time].gsub('.js','').to_i
    @event = @video.events.select{|x| x.happened_at < @video.recorded_at + time && x.event_type == 'scene'}.last
    @sub_scene = SubScene.new(
    :happened_at => @video.recorded_at + time)
      respond_to do |format|
      format.html {render :action => 'annot_form'}
      format.js {render :action => 'sub_annot_form',:layout => false} 
      end
  end
  def create_sub_annotation
    
    event = Event.find(params[:id])
    subscene = SubScene.create(params[:sub_scene])
    event.sub_scenes << subscene
    @video = Video.find(event.video_id, :include => [{:events => :sub_scenes}])
    respond_to do |format|
      format.html {render :action => ''}
      format.js {render :partial => 'new_annot',:layout => false} 
    end
  end
  def add_annotation
    @create = true
    @video = Video.find(params[:id])
    set_current_piece(params[:piece_id].gsub('.js','').to_i)
    time = params[:time].gsub('.js','').to_i
    @event = Event.new
    @event.video_id = @video.id
    @event.event_type = 'scene'
    @event.happened_at = @video.recorded_at + time
    @event.performers = []
    
    respond_to do |format|
      format.html {render :action => 'annot_form'}
      format.js {render :partial => 'annot_form',:layout => false} 
    end
  end
  def create_annotation
    params[:performers] ||= []
    @video = Video.find(params[:vid_id])
    @event = Event.create_annotation(params,current_user,@video,session[:pieceid])
    @event.save
    respond_to do |format|
      format.html {render :action => ''}
      format.js {render :partial => 'new_annot',:layout => false} 
    end
  end
  def add_marker
    
    @video = Video.find(params[:id])
    set_current_piece(params[:piece_id].gsub('.js','').to_i)
    time = params[:time].gsub('.js','').to_i
    @event = Event.create(
    :title => 'marker',
    :description => '',
    :modified_by => current_user.login,
    :piece_id => current_piece.id,
    :created_by => current_user.login,
    :video_id => @video.id,
    :event_type => 'marker',
    :happened_at => @video.recorded_at + time,
    :performers => []
    )
    respond_to do |format|
      format.html {render :action => ''}
      format.js {render :partial => 'new_annot',:layout => false} 
    end
  end
  
  def move_from_viewer
    @event = Event.find(params[:id])
    time = params[:time].gsub('.js','')
    @event.happened_at = @event.video.recorded_at + time.to_i
    @event.save
    @event.check_for_reposition
    @video = @event.video
    respond_to do |format|
      format.html
      format.js
    end
  end
  def set_out
    @event = Event.find(params[:id])
    @video = @event.video
    time = params[:time].gsub('.js','').to_i
    moment = @video.recorded_at + time
    start_time = @event.happened_at
    @event.dur = (moment - start_time).to_i
    @event.save
    @video = @event.video
    respond_to do |format|
      format.html
      format.js {render :action => 'move_from_viewer'}
    end
  end
  def edit_annotation
    #puts up the modify form
    @create = false
    @event = Event.find(params[:id])
    @video = @event.video
    @modify = true
    respond_to do |format|
      format.html
      format.js {render :partial => 'annot_form', :layout => false} 
    end
  end
  def rate
    @event = Event.find(params[:id])
    @event.rating = params[:rating].to_i
    @event.save
    @video = @event.video
    respond_to do |format|
      format.html { redirect_to :action => "present", :id => session[:pieceid] }
      format.js {render :partial => 'new_annot', :layout => false} 
    end
  end
  def update_annotation
    event = Event.find(params[:id])
    event.do_event_changes(params,current_user) 
    event.save
    @video = event.video
    respond_to do |format|
      format.html
      format.js {render :partial => 'new_annot', :layout => false} 
    end
  end

  def new_list
    if params[:search_term].present?
      @events = Video.find_all_by_piece_id(
                params[:id],
                :conditions => filter_from_universal_table_params(filt),
                :order => sort_from_universal_table_params,
                :include => [:video_recordings,:events,:subjects]
                )
    end
  end
  def list
    redirect_non_admins('normal_actions',home_url) and return
    if params[:id]
      @piece = Piece.find_by_id(params[:id])
      @events = Event.find_all_by_piece_id(params[:id])
      # @events = Event.paginate_all_by_piece_id(
      #                       params[:id],
      #                       :per_page => 50,
      #                       :page => params[:page],
      #                       :order => sort_from_universal_table_params,
      #                       :include => [:piece])
    else
      redirect_non_admins('group_admin',home_url) and return
      @events = Event.paginate(
                      :per_page => 50,
                      :page => params[:page],
                      :order => sort_from_universal_table_params,
                      :include => [:piece])
    end
  end
  def list_trash
    @events = Event.paginate_all_by_state('deleted',
                    :per_page => 50,
                    :page => params[:page],
                    :order => sort_from_universal_table_params,
                    :include => [:piece])
    render :action => 'list'
  end
  def show
    @event = Event.find(params[:id])
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    params[:event][:performers] = params[:event][:performers].split(',')
    params[:event][:highlighted] ||= false
    params[:event][:inherits_title] ||= false
    if @event.update_attributes(params[:event])
      flash[:notice] = 'Event was successfully updated.'
      redirect_to :action => 'show', :id => @event
    else
      render :action => 'edit'
    end
  end

  def destroy
    redirect_non_admins('normal_actions',home_url) and return
    event = Event.find(params[:id])
    event.destroy
    redirect_to :action => 'list'
  end
  def delete_ev #delete from event list
    redirect_non_admins('normal_actions',home_url) and return
    event = Event.find(params[:id])
    event.destroy
    redirect_to url_for(params[:came_from])
  end


# my own methods


end
