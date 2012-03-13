class MetaInfosController < ApplicationController
  layout 'standard'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    redirect_non_admins and return
    if user_has_right('group_admin')
      @meta_infos = MetaInfo.find(:all)
    else
      redirect_to pieces_url
    end
  end
  
  def list_by_piece
    @piece = set_current_piece(params[:id])
    @meta_infos = @piece.meta_infos
  end
  def show
    @meta_info = MetaInfo.find(params[:id])
  end

  def new
    @meta_info = MetaInfo.new
  end

  def create
    @meta_info = MetaInfo.new(params[:meta_info])
    @meta_info.created_by = current_user.login
    @meta_info.piece_id = session[:pieceid]
    if @meta_info.save
      flash[:notice] = 'MetaInfo was successfully created.'
      redirect_to :controller => 'meta_infos', :action => 'list_by_piece', :id => session[:pieceid]
    else
      render :action => 'new'
    end
  end

  def edit
    @meta_info = MetaInfo.find(params[:id])
  end

  def update
    @meta_info = MetaInfo.find(params[:id])
    if @meta_info.update_attributes(params[:meta_info])
      flash[:notice] = 'MetaInfo was successfully updated.'
      redirect_to :action => 'show', :id => @meta_info
    else
      render :action => 'edit'
    end
  end

  def destroy
    meta = MetaInfo.find(params[:id])
    meta.destroy
    redirect_to :action => 'list_by_piece', :id => meta.piece_id
  end
end
