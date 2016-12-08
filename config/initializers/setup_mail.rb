#ActionMailer::Base.smtp_settings = {
#	:address              => "mail.coffeemobile.com",
#	:port                 => 25,
#	:domain               => "coffeemobile.com",
#	:user_name            => "noreply@coffeemobile.com",
#	:password             => "c3chensi",
#	:authentication       => "plain",
#	:tls => true,
#	:enable_starttls_auto => false,
#  :openssl_verify_mode  => 'none',
#	:address => "localhost",
#	:port => 25
#}

#ActionMailer::Base.default_url_options[:host] = "localhost:3000"
#Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?

ActionMailer::Base.smtp_settings = {
  :user_name => 'xdsdcx',
  :password => '%cFErr$1R/15',
  :domain => 'myshyft.com',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}
