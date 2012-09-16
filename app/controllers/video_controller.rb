class VideoController < ApplicationController
  layout 'standard'
  before_filter :get_video_from_params, :only => [:delete, :delete_all]
  def get_video_from_params
      @video = Event.find(params[:id])
      @piece = @video.piece
  end
  def new_list
    @videos = Event.where("event_type = 'video'").includes([:piece])
  end
  def index
    new_list
    render :action => 'new_list'
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
