require "net/smtp"
require "securerandom"
require "base64"

FOOTER = "\n\n-----\nThis mail was issued by Ruby #{RUBY_VERSION} on Arch Linux (x86_64)."

def send_mail(server, from, to, subject, body)
  Net::SMTP.start(server[:host], server[:port], `uname -n`.chomp, server[:user], server[:pass], :cram_md5) do |smtp|
    smtp.send_message(
      "Message-Id: <#{SecureRandom.uuid}@#{server[:host]}>\n" + \
      "From: \"#{from[:name]}\" <#{from[:addr]}>\n" + \
      "To: \"#{to[:name]}\" <#{to[:addr]}>\n" + \
      "Subject: #{subject}\n" + \
      "Content-Type: text/plain; charset=utf-8\n" + \
      "Content-Transfer-Encoding: base64\n" + \
      "\n" + \
      Base64.encode64(body),
      from[:addr], to[:addr])
    smtp.finish
  end
end

server = {
  :host => "example.com",
  :port => 587,
  :user => gets.chomp,
  :pass => gets.chomp,
}

from = {
  :name => "Fugao Hogeta",
  :addr => server[:user],
}

to = {
  :name => "Hageo Higeta",
  :addr => "huga@hoge.com",
}

subject = ""
body = "てすとめーるだよ。ほげほげふがふが。"
body += FOOTER

send_mail(server, from, to, subject, body)