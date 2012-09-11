class ViewerController < ApplicationController
    layout 'standard'
    skip_before_filter :verify_authenticity_token
    before_filter :get_video_from_params, :only => [:edit, :show, :update, :delete, :delete_all, :connect_event_and_video, :upload_one, :update_from_viewer]
    def get_video_from_params
      @video = Video.find(params[:id])
    end

    def viewer
      @video = Event.find(params[:id])
      @event = Event.find(params[:event_id]) if params[:event_id]
      @piece = Piece.find(params[:piece_id]) if params[:piece_id]
      @ur = request.host
      
      if SetupConfiguration.app_is_local? && @video.online?
        @flow_type = 'local_plain'
      elsif @video_is_uploaded
        @flow_type = 's3'
      else
        @flow_type = false
      end

      if @flow_type
        respond_to do |format|
          format.html
        end
      else
        flash[:error] = 'Video is not available!'
        redirect_to request.referrer
      end
    end

    def prepare_params
      params[:video][:piece_id] = params[:piece_id].present? ? params[:piece_id] : nil
      params[:video][:is_uploaded] = params[:video][:is_uploaded].present? ? params[:video][:is_uploaded] : nil
      params[:video][:meta_data] = params[:video][:meta_data].present? ? params[:video][:meta_data] : nil
    end

    def edit_from_viewer
        @video = Event.find(params[:id])
        respond_to do |format|
          format.html
          format.js {render :layout => false}
        end
    end
    def update
      prepare_params
      @video.attributes = params[:video]
      @video.save
      flash[:notice] = "Updated #{@video.title}"
      @flash_message = flash[:notice]
      respond_to do |format|
        format.html {redirect_to params[:came_from]}
        format.js {render :layout => false}
      end
    end

    def index #make this work without pieceid

      
      sorter = params[:sorter] ? params[:sorter] : 'id'
      order_by = params[:order] ? params[:order] : 'DESC'
      @order = order_by == 'ASC' ? 'DESC' : 'ASC'
      sorts = {'title' => 'title','id' => 'id'}
      if params[:id]
        @piece = Piece.find(params[:id])
        @videos = @piece.videos.paginate(
                  :limit => 50,
                  :conditions => filter_from_universal_table_params(),
                  :page => params[:page],
                  :order => sort_from_universal_table_params,
                  :include => [:events]
                  )
      else
        @videos = Video.paginate(
                  :limit => 50,
                  :conditions => filter_from_universal_table_params(),
                  :page => params[:page],
                  :order => sort_from_universal_table_params,
                  :include => [:events]
                  )
      end
       
        
      
    end

    def edit
      @return_to = params[:from]  
    end
    def show
      @return_to = params[:from]
    end

    
    def new
      @video = Video.find(params[:id1])
      @piece = Piece.find(params[:id2])
      @prefix = @video.s3_prefix
    end

    def delete
      if @video.destroy
        flash[:notice] = "destroyed video id: #{params[:id]}"
      else
        flash[:notice] = 'could not destroy video'
      end
      redirect_to :action => 'index', :id => session[:pieceid]
    end

    def delete_all
      if @video.destroy_all
        flash[:notice] = "destroyed video id: #{params[:id]} and its s3 files"
      else
        flash[:notice] = 'could not destroy video'
      end
      redirect_to :action => 'index', :id => session[:pieceid]
    end



    #########from events controller
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
    @video = Event.find(params[:id])
    set_current_piece(params[:piece_id].gsub('.js','').to_i)
    time = params[:time].gsub('.js','').to_i
    @event = Event.new
    @event.video_id = @video.id
    @event.event_type = 'scene'
    @event.happened_at = @video.happened_at + time
    @event.performers = []
    
    respond_to do |format|
      format.html {render :action => 'annot_form'}
      format.js {render :partial => 'annot_form',:layout => false} 
    end
  end
  def create_annotation
    params[:performers] ||= []
    @video = Event.find(params[:vid_id])
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

    #####check these

    def create #whats this for
      video = Video.create(
        params[:video]
      )
      video.save
      flash[:notice] = 'created new archive video'
      redirect_to :action => 'index'
    end

end
