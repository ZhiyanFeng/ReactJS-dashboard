# == Schema Information
#
# Table name: api_keys
#
#  id           :integer          not null, primary key
#  access_token :string(255)
#  app_platform :string(255)
#  app_version  :string(255)
#  is_valid     :boolean          default(TRUE)
#  created_at   :timestamp
#  updated_at   :timestamp
#

class ApiKey < ActiveRecord::Base
  attr_accessible :app_version, :app_platform
  
  before_create :prep_record
  
  validates_presence_of :app_platform
  validates_presence_of :app_version
  
  def prep_record
    self.access_token = SecureRandom.hex
  end
end
