class RpushNotification < ActiveRecord::Base
  attr_accessible :device_token, :data
  
end
