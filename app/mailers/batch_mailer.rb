class BatchMailer < ActionMailer::Base
  default from: 'batches@archives.clevelandart.org'
   
  def batch_started_email users, batch, directories
    @users = users
    @batch = batch
    @directories = directories

    recipients = @users.map { |u| u.email }
    mail(
      to: recipients, 
      subject: "Archival repository batch initiated for #{@batch.title.first}"
    ) 
  end
end
