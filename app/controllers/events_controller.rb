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
      @events = Event.find_all_by_piece_id(@piece.id)
    else
      redirect_non_admins('group_admin',home_url) and return
      @events = Event.all
    end
  end
  def list_trash
    @events = Event.find_all_by_state('deleted',
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
    if params[:piece_id]
      id = params[:piece_id].to_s
    end
    redirect_non_admins('normal_actions',home_url) and return
    event = Event.find(params[:id])
    event.destroy
    redirect_to :action => 'list', :id => id
  end


# my own methods


end
