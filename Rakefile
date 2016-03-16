require 'rubygems'
require 'bundler'
require 'time'
Bundler.require

require './lib/devdigest'
require './lib/dd/gh'

desc "Run the digest and print to stdout"
task :digest do
  since = Time.now-24*60*60
  puts Devdigest.new(since).run
end

desc "Email daily digest"
task :daily_email do

  case Time.now.wday
  when 0, 6
    puts "Skipping weekend"
    next
  when 1 # monday
    since = Time.now-3*24*60*60
    puts "Monday - fetching activity since #{since}"
  else   # regular weekday
    since = Time.now-24*60*60
    puts "Weekday - fetching activity since #{since}"
  end

  digest    = Devdigest.new(since).run
  markdown  = RDiscount.new(digest)
  team      = ENV["TEAM_NAME"] || "Team"
  subject   = "#{team} digest - #{Time.now.strftime("%A")}"

  Pony.mail({
    :to      => ENV["EMAIL_TO"],
    :from    => ENV["EMAIL_FROM"],
    :subject => subject,
    :headers => { "Content-Type" => "text/html" },
    :body    => markdown.to_html,

    :via => :smtp,
    :via_options => {
      :address        => ENV["MAILGUN_SMTP_SERVER"] || ENV["SMTP_SERVER"] || "smtp.sendgrid.net",
      :port           => ENV["MAILGUN_SMTP_PORT"] || ENV["SMTP_PORT"] || 587,
      :user_name      => ENV["MAILGUN_SMTP_LOGIN"] || ENV["SMTP_LOGIN"],
      :password       => ENV["MAILGUN_SMTP_PASSWORD"] || ENV["SMTP_PASSWORD"],
      :authentication => :plain,
      :domain         => "spreedly.com",
      :enable_starttls_auto => true
    }
  })

  puts "Emailed #{ENV["EMAIL_TO"]}."
end
