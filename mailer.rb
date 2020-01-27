require 'net/smtp'
require 'tlsmail'
require 'dotenv'
Dotenv.load("#{__dir__}/.env")

def send_email(from, to, mailtext)
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
  message = <<~MESSAGE_END
    From: Luciano <#{ENV["EMAIL_ADDRESS"]}>
    To: Luciano <#{ENV["MAIL_TO_ADDRESS"]}>
    Subject: There are OINP Updates!

    Your system identified a change in the OINP 2020 updates page. Please check it out.
    link: https://www.ontario.ca/page/2020-ontario-immigrant-nominee-program-updates

    new pagebody:
    #{updates}

  MESSAGE_END

  send_email(ENV["EMAIL_ADDRESS"], ENV["MAIL_TO_ADDRESS"], message)
end
