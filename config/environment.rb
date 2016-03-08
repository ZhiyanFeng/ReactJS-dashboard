# Load the Rails application.
require File.expand_path('../application', __FILE__)

require 'yaml'
require 'json'

ENV['RAILS_ENV']="development"

ENV_VARS = YAML.load_file("#{Rails.root}/config/environment_variables.yml")

# Initialize the Rails application.
Expresso::Application.initialize!

