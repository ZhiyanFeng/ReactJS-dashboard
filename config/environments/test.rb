require 'syslog/logger'

Expresso::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  #config.assets.compress = false
  #config.assets.compile = true
  config.serve_static_assets = false
  #config.assets.precompile = ['*.jpeg', '*.jpg', '*.png' ,'*.js', '*.css', '*.css.erb', '*.svg', '*.eot', '*.woff', '*.ttf']
  #config.assets.precompile += %w( *.css *.js *.woff *.eot *.svg *.ttf)
  config.autoload_paths += %W(#{config.root}/app/middleware/)
  config.assets.digest = true
  config.log_level = :debug
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify  
  config.eager_load = true
  config.logger = Syslog::Logger.new

  #Paperclip options
  Paperclip.options[:command_path] = "/usr/bin/"
  config.paperclip_defaults = {
    :url => ":s3_path_url",
    :path => "/images/:style/:id_:basename.:extension",
    :styles => {},
    :default_url => "",
    :default_style => :original,
    :validations => {},
    :storage => :s3,
    :s3_credentials => "#{config.root}/config/s3.yml"
  }
  
  if Rails.env.production?
    config.action_mailer.default_url_options = {
      :host => "www.coffeemobile.com"
    }
  else
    config.action_mailer.default_url_options = {
      :host => "www.coffeemobile.com"
    }
  end
  
  ENV['S3_KEY'] = "AKIAJ5DWZZYJIDXW3W2A"
  ENV['S3_SECRET'] = "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"
  ENV['S3_ASSET_URL'] = ":s3_domain_url"
  ENV['S3_BUCKET_NAME'] = "comovideos"
end
