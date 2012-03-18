class VideoController < ApplicationController
  layout 'standard'
    skip_before_filter :verify_authenticity_token
    before_filter :get_video_from_params, :only => [:edit, :show, :update, :delete, :delete_all, :connect_event_and_video, :upload_one, :update_from_viewer]
    def get_video_from_params
      @video = Video.find(params[:id])
    end

    def viewer
      @flow_type = false
      @video = Video.find(params[:id]).includes([{:events => :sub_scenes}])
      @event = Event.find(params[:event_id]) if params[:event_id]
      @piece = Piece.find(params[:piece_id]) if params[:piece_id]
      @ur = request.host
      if !SetupConfiguration.app_is_local? && @video.fn_s3
        @flow_type = 's3'
      else
        begin
          File.open(@video.full_uncompressed_path)
          line = true
        rescue
          line = false
        end
        if @video.fn_local && line
            @flow_type = SetupConfiguration.pseudostreaming_type
        elsif  @video.fn_arch  && Video.archive_dir_online?
            @flow_type = 'arch'
        elsif @video.fn_s3
          if SetupConfiguration.cdn?
            @flow_type = 's3'
          else
            @flow_type = 's3_plain'
          end
        end
      end
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
      params[:video][:fn_local] = params[:video][:fn_local].present? ? params[:video][:fn_local] : nil
      params[:video][:fn_arch] = params[:video][:fn_arch].present? ? params[:video][:fn_arch] : nil
      params[:video][:fn_s3] = params[:video][:fn_s3].present? ? params[:video][:fn_s3] : nil
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

    
    def index_delayed_jobs
      @djs = DelayedJob.where(filter_from_universal_table_params).order(sort_from_universal_table_params)
    end
    def destroy_delayed_job
      dj = DelayedJob.find(params[:id])
      if dj.locked_at
        flash[:notice] = "This job is busy. I don't think it's a good idea to destroy it now."
      else
        dj.destroy
        flash[:notice] = "Destroyed Job"
      end
      redirect_to :action => 'index_delayed_jobs'
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

    def upload_compressed_to_s3
      #should get contents of compressed folder then intellegently decide which video it is and upload it to s3 giving it the correct path
      # if there is no force param it only shows a list
      @list_of_uploading_videos = Video.upload_compressed_folder(params[:force])
    end

    def delete_all #only used in mysterious _insert_videos partial
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

    def mark_as_uploaded #used by delayed job to send updated info to heroku
      if video = Video.find_by_id(params[:id])
        video.mark_in('s3')
        render :text => "#{video.title} OK "
      else
        render :text => "Video #{params[:id].to_s} failed to mark as uploaded."
      end
    end
    
    def process_days_videos
      piece = Piece.find(params[:id])
      Video.send_later :update_heroku
      sleep 2
      @video_ids = piece.todays_videos_ids
      Video.delayed_upload_videos(@video_ids)
    end
    
    
    ################ what are these ?
    
    
  def compress_days_videos #try out needs link to and view
    piece = Piece.find(params[:id])
    @video_ids = piece.todays_videos_ids
    Video.delayed_compress_videos(@video_ids)
  end

  
  def upload_one #needs a link to and view
    @video.delayed_dearchive_compress_and_upload
  end

end