class Notifier < ActionMailer::Base

  def notify_david(subject, recipient, message_body, from, sent_at = Time.now)
    @subject    = 'Piecemaker Inquiry'
    @body       = {:message_body => message_body, :sent_from => from,:subject_from => subject}
    @recipients = recipient
    @from       = 'info@piecemaker.org'
    @sent_on    = sent_at
    @headers    = {}
  end

end