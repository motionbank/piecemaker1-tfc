class HomeController < ApplicationController
  layout 'standard'
  #before_filter :unset_current_piece
  def welcome
    @title = 'Welcome to Piecemaker '
    if current_user
      @pieces = Piece.all
    end
    respond_to do |format|
      format.html
    end
  end

  def contact
    @title = 'Contact'
    if request.post?
      Notifier.notify_david(params['Email'],params['Subject'],message_body = params['Message']).deliver
      flash[:notice] = 'Thank you for your message.'
      redirect_to :action => :welcome
    end

  end

end
