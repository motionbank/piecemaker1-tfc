class NotesController < ApplicationController
  
  before_filter :redirect_non_admins
  
  layout  "standard"
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #          :redirect_to => { :action => :list }

  def list
    @notes = Note.find(:all)
  end

  def show
    @note = Note.find(params[:id])
  end

  def new
    @note = Note.new
  end

  def create
    @note = Notes.new(params[:notes])
    @note.event_id = params[:event_id]
    @note.created_by = params[:created_by]
    if @note.save
      flash[:notice] = 'Note was successfully created.'
      redirect_to :controller => 'capture', :action => 'present', :id => session[:pieceid]
    else
      render :action => 'new'
    end
  end

  def edit
    @note = Note.find(params[:id])
  end

  def update
    @note = Note.find(params[:id])
    if @note.update_attributes(params[:notes])
      flash[:notice] = 'Note was successfully updated.'
      redirect_to :action => 'show', :id => @note
    else
      render :action => 'edit'
    end
  end

  def destroy
    Note.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
