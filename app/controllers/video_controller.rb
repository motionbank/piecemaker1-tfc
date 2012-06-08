class VideoController < ApplicationController
  layout 'standard'
    skip_before_filter :verify_authenticity_token
    before_filter :get_video_from_params, :only => [:edit, :show, :update, :delete, :delete_all, :connect_event_and_video, :upload_one, :update_from_viewer]
    def get_video_from_params
      @video = Video.find(params[:id])
    end

    def viewer
      @flow_type = false
      @video = Video.find(params[:id])
      @event = Event.find(params[:event_id]) if params[:event_id]
      @piece = Piece.find(params[:piece_id]) if params[:piece_id]
      @ur = request.host
      @flow_type = 'local_plain'
      #@flow_type = @video.fn_s3 ? 'rtmp' : 'file'
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
        @video = Video.find(params[:id])
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
        