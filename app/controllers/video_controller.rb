class VideoController < ApplicationController
  layout 'standard'
  before_filter :get_video_from_params, :only => [:delete, :delete_all, :new, :delete_from_menu]
  def get_video_from_params
      @video = Event.find(params[:id])
      @piece = @video.piece
  end
  def new

  end
  def edit
    @event = Event.find(params[:id])
    render :layout => false
  end
  def update
    @video = Event.find(params[:id])
    @video.update_attributes(params[:event])
    respond_to do |format|
      format.js {render :partial => 'update_index', :layout => false;}
    end
  end
  def index
    if params[:id]
      @videos = Event.where("event_type = 'video' AND piece_id = #{params[:id]}").includes([:piece])
    else
      @videos = Event.where("event_type = 'video'").includes([:piece])
    end
  end
  def delete_from_menu
    if @video.destroy
      respond_to do |format|
        format.js {render :partial => 'delete_from_menu', :layout => false}
      end
    else
    end
  end
  def delete
    if @video.destroy
      flash[:notice] = "destroyed video id: #{params[:id]}"
    else
      flash[:notice] = 'could not destroy video'
    end
    redirect_to :action => 'index', :id => @piece.id
  end

  def delete_all
    if @video.destroy_all
      flash[:notice] = "destroyed video id: #{params[:id]} and its s3 files"
    else
      flash[:notice] = 'could not destroy video'
    end
    redirect_to :action => 'index', :id => @piece.id
  end
end
