class VideoController < ApplicationController
  layout 'standard'
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
end
