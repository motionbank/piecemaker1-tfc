class Notifier < ActionMailer::Base
  def notify_david(user_email,user_subject,user_message)
    @user_email = user_email
    @user_subject = user_subject
    @user_message = user_message
    mail(:to => 'nutbits@gmail.com', :subject => "Piecemaker Inquiry", :from => "info@piecemaker.org")
  end
end