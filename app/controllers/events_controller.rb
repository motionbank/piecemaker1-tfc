class EventsController < ApplicationController
  layout 'standard', :except => 'unlock'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #          :redirect_to => { :action => :list }

  def list
    redirect_non_admins('normal_actions',home_url) and return
    if params[:id]
      @piece = Piece.find_by_id(params[:id])
      @events = Event.paginate(
                            :conditions => "piece_id = '#{params[:id]}'",
                            :per_page => 50,
                            :page => params[:page],
                            :order => sort_from_universal_table_params,
                            :include => [:piece])
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
    @events = Event.paginate(
                    :per_page => 50,
                    :conditions => "state = 'deleted'",
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
