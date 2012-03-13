class HomeController < ApplicationController
  layout 'standard'
  #before_filter :unset_current_piece
  def welcome
    @title = 'Welcome to Piecemaker'
    if current_user && mobile_device?
      @pieces = Piece.all
    end
    respond_to do |format|
      format.html
      format.mobile
    end
  end

  def contact
    @title = 'Contact'
    if (request.post?)
      subject = params['Subject']
      message_body = params['Message']
      from = params['Email']
      message_to_david = Notifier.create_notify_david(subject, 'nutbits@gmail.com', message_body, from)
      Notifier.deliver(message_to_david)
      flash[:notice] = 'Thank you for your message.'
      redirect_to :action => :welcome
    else
      
    end
  end

end
