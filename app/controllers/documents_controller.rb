class DocumentsController < ApplicationController

  layout "standard"
  before_filter :get_document_by_params_and_redirect_wrong, :only => [:show,:edit,:update,:destroy]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #          :redirect_to => { :action => :list }
  def get_document_by_params_and_redirect_wrong
    @document = Document.find(params[:id])
  end

  def index
    redirect_non_admins('group_admin') and return
    @documents = Document.all
  end

  def list_by_piece
    @piece = set_current_piece(params[:id])
    @documents = @piece.documents.sort_by{|x| x.doc_file_name}
    @videos = @piece.videos
    @photos = @piece.photos
  end

  def show
  end

  def new
    set_current_piece(params[:id])
    @document = Document.new
    @document.piece_id = params[:id]
    @document.save
    @prefix = @document.s3_prefix
    unless(current_piece)
      flash[:notice] = 'You can\'t upload a document unless a piece is chosen.'
      redirect_to pieces_url
    end
    respond_to do |format|
      format.html {render :action => 'new', :layout => 'standard'}
      format.js {render :action => 'new.html.erb', :layout => false}
    end
  end

  def cancel_new

    if @doc = Document.find(params[:id]) and !@doc.doc_file_size
      piece_id = @doc.piece_id
      @doc.destroy
    end
    respond_to do |format|
      format.html {redirect_to :action => 'list_by_piece', :id => piece_id }
      format.js {render :action => 'cancel_new',:layout => false}
    end
  end
  def create

    #  id               :integer(4)      not null, primary key
    #  doc_file_name    :string(255)
    #  doc_content_type :string(255)
    #  doc_file_size    :integer(4)
    #  piece_id         :integer(4)
    #  created_at       :datetime
    #  updated_at       :datetime
    #
    @document = Document.find(params[:vid_id])
    @document.update_from_params(params)
    if @document.save
      flash[:notice] = 'Document was successfully created.'
     redirect_to :action => 'list_by_piece', :id => @document.piece_id
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @document.update_attributes(params[:document])
      flash[:notice] = 'Document was successfully updated.'
      redirect_to :action => 'show', :id => @document
    else
      render :action => 'edit'
    end
  end

  def destroy
    piece_id = @document.piece_id
    if @document.destroy_all
      flash[:notice] = "destroyed doc id: #{params[:id]}"
    else
      flash[:notice] = 'could not destroy doc'
    end
    redirect_to :action => 'list_by_piece', :id => piece_id
  end

end
