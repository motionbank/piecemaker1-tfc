class PiecesController < ApplicationController
  
  layout  "standard", :except => :printme
  before_filter :set_defaults
  before_filter :get_piece_from_params, :only => [:edit, :list_tags, :destroy, :update, :destroy_drafts]

  
  def get_piece_from_params
    @piece = Piece.find(params[:id])
  end
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
         #:redirect_to => { :action => :list }

    

  def list
    unset_current_piece
    @title = 'Pieces'
    @piecess = Piece.order(sort_from_universal_table_params('title'))
    respond_to do |wants|
      wants.html {  }
    end
  end
  def word_stats
    @piece = Piece.find(params[:id])
    @stats = @piece.word_statistics
  end
  def show 
     @piece = set_current_piece(params[:id])
  end
  
  def unlock_event
    event = Event.find(params[:id])
    event.unlock
    event.save
    redirect_to :action => 'show', :id => event.piece_id
  end
  
  def new
    @piece = Piece.new
    @performers = User.performers
  end

  def edit
    @performers = User.performers
    respond_to do |wants|
      wants.html {  }
      wants.js { render :layout => false}
    end
  end

  def update
    params[:piece][:is_active] ||= false
    params[:piece][:performer_ids] ||= []
    if @piece.update_attributes(params[:piece])
      @piece.save
      flash[:notice] = 'Piece was successfully updated.'
      redirect_to :action => 'show', :id => @piece
    else
      render :action => 'edit'
    end
  end


  def destroy #TODO make sure this destroys all events
    @piece.destroy
    redirect_to :action => 'list'
  end

  def normalfy_event
    event = Event.find(params[:id])
    event.make_normal
    event.save
    redirect_to :action => 'show', :id => event.piece_id
  end
  def destroy_drafts
    @piece.events.each do |ev|
      ev.destroy if ev.is_draft?
    end
    redirect_to :action => 'show', :id => @piece.id
  end

  def empty_trash
    piece = Piece.find(params[:id])
    events = piece.events.deleted
    events.each do |event|
      event.destroy
    end
    redirect_to :controller => 'pieces', :action => 'show', :id => params[:id]
  end
  
  def list_tags
  end

  def edit_tag
    if request.post?
      tag = Tag.find(params[:id])
      tag.name = params[:tag][:name]
      tag.save
      redirect_to :action => 'show', :id => tag.piece_id
    else
       @tag = Tag.find(params[:id])
    end   
  end
  
  def destroy_tag
    tag = Tag.find(params[:id])
    piece_id = tag.piece_id
    tag.destroy
    redirect_to :action => 'show', :id => tag.piece_id
  end

  
  ############

  def create   #creates a new piece and a new version
    @piece = Piece.new(params[:piece])
    if @piece.save
      flash[:notice] = 'Piece was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end


  def video
    @dvd_number = params[:id]
  end


end
