class MarkerController < ApplicationController
#   <span class="short-cut">M </span>
# <%= link_to('New Marker',{:action => 'new_marker',:id => 'marker'}, :class => 'jsc dg mprep', :id => 'marker')-%>
# <br />

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
end
