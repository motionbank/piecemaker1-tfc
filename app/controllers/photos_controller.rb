class PhotosController < ApplicationController
  
  layout  "standard"
  def index
    redirect_non_admins and return
    @photos = Photo.paginate(
                    :per_page => 50,
                    :page => params[:page],
                    :order => sort_from_universal_table_params
                    )
  end

  def new
    @piece = Piece.find(params[:id])
    @photo = Photo.new
    @photo.piece_id = @piece.id
    @photo.save
    @prefix = @photo.s3_prefix
    respond_to do |format|
      format.html{}
    end
  end

  def show
    @photo = Photo.find params[:id]
  end


  def delete_from_gallery
    photo = Photo.find(params[:id])
    photo.destroy if photo.destroy_all_styles
    
    respond_to do |format|
      format.js {render :text => 'new',:layout => false}
    end
  end
  def cancel_new
    
    if @photo = Photo.find(params[:id])
      piece_id = @photo.piece_id
      @photo.destroy
    end
    respond_to do |format|
      format.html {redirect_to :action => 'gallery', :id => piece_id }
      format.js {render :action => 'cancel_new',:layout => false} 
    end
  end
  def create
    # 
    # @photo = Photo.new params[:photo]
    # @photo.note_id = params[:note_id]
    # @photo.save
    # note = Note.find(params[:note_id])
    # note.img = @photo.id
    # note.save

    @photo = Photo.find(params[:id])
    @photo.create_from_params(params)
    Photo.send_later(:create_thumbnail, @photo)
    redirect_to :action => 'gallery', :id => @photo.piece_id
  end
  def gallery
    
    if(set_current_piece(params[:id]))
        @photos = Photo.find_all_by_piece_id(params[:id])
    else
      flash[:notice] = "I couldn't find this piece!"
      redirect_to :controller => pieces_url
    end
  end
end
