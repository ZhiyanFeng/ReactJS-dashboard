require 'syslog/logger'
RAILS_DEFAULT_LOGGER = Syslog::Logger.new

Expresso::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Do not compress assets
  config.assets.compress = true
  config.assets.compile = true
  config.serve_static_assets = false
  
  config.eager_load = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.perform_deliveries = true
  #config.assets.precompile = ['*.jpeg', '*.jpg', '*.png' ,'*.js', '*.css', '*.css.erb', '*.svg', '*.eot', '*.woff', '*.ttf']
  config.assets.precompile += %w( *.css *.js *.woff *.eot *.svg *.ttf)
  config.autoload_paths += %W(#{config.root}/app/middleware/)
  config.assets.paths << Rails.root.join("app", "assets", "fonts")

  # Add the fonts path
  #config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

  # Precompile additional assets

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  Paperclip.options[:command_path] = "/usr/local/bin/"
  config.paperclip_defaults = {
    :url => ":s3_domain_url",
    :path => "/images/:style/:id_:basename.:extension",
    :styles => {},
    :default_url => "",
    :default_style => :original,
    :validations => {},
    :storage => :s3,
    :s3_credentials => "#{config.root}/config/s3.yml"
  }
  
  ENV['S3_KEY'] = "AKIAJ5DWZZYJIDXW3W2A"
  ENV['S3_SECRET'] = "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"
  ENV['S3_ASSET_URL'] = ":s3_domain_url"
  ENV['S3_BUCKET_NAME'] = "comovideos"

  ENV['S3_BUCKET'] = "coffeemobile_development"
end
