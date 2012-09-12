class VideoController < ApplicationController
  layout 'standard'
  before_filter :get_video_from_params, :only => [:delete, :delete_all]
  def get_video_from_params
      @video = Event.find(params[:id])
      @piece = @video.piece
  end
  def index #make this work without pieceid
        sorter = params[:sort] ? params[:sort] : 'id'
        order_by = params[:order] ? params[:order] : 'DESC'
        @order = order_by == 'ASC' ? 'DESC' : 'ASC'
        sorts = {'title' => 'title','id' => 'id'}
        if params[:id]
          @piece = Piece.find(params[:id])
          @videos = @piece.unordered_videos.paginate(
                    :limit => 50,
                    :conditions => filter_from_universal_table_params(),
                    :page => params[:page],
                    :order => sort_from_universal_table_params,
                    :include => [:subjects]
                    )
        else
          @videos = Event.videos.paginate(
                    :limit => 50,
                    :conditions => filter_from_universal_table_params(),
                    :page => params[:page],
                    :order => sort_from_universal_table_params,
                    :include => [:subjects]
                    )
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
