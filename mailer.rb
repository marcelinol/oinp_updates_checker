require 'net/smtp'
require 'tlsmail'
require_relative "file_handler"
require 'dotenv'
Dotenv.load("#{__dir__}/.env")

def send_email(from, mailtext, to)
  configs = {
    server_address: 'smtp.gmail.com',
    domain: 'gmail.com',
    username: ENV['EMAIL_ADDRESS'],
    password: ENV['EMAIL_PASSWORD'],
    port: 587,
    authentication: :plain
  }
  begin
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    Net::SMTP.start(
      configs[:server_address],
      configs[:port],
      configs[:domain],
      configs[:username],
      configs[:password],
      configs[:authentication]
    ) do |smtp|
      smtp.send_message mailtext, from, to
    end
  rescue => e
    raise "Exception occured: #{e} "
    exit -1
  end
end

def send_email_about_oinp_updates(updates)
  puts "sending email"
  message = <<~MESSAGE_END
    From: Luciano <#{ENV["EMAIL_ADDRESS"]}>
    To:
    Subject: OINP Update!

    Your system identified a change in the OINP 2020 updates page. Please check it out.
    link: https://www.ontario.ca/page/2020-ontario-immigrant-nominee-program-updates

    new pagebody:
    #{updates}

  MESSAGE_END

  FileHandler.new.download_users
  file_path = FileHandler.local_path(filename: FileHandler::USERS_FILENAME)
  mails_to = File.open(file_path, "r:UTF-8", &:read).split(",")
  send_email(ENV["EMAIL_ADDRESS"], message, mails_to)
end
