# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# これがなくてもExceptionNotifierで送信できたが、送信元が適当になってたので一応残しておく
ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => "hogehoge",
  :authentication => :plain,
  :user_name => "sakikazu15@gmail.com",
  :password => 'saki0745'
}
