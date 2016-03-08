class SmsStop < ActiveRecord::Base
  attr_accessible :plivo_number, :stop_number
  
  validates_presence_of :plivo_number, :on => :create
  validates_presence_of :stop_number, :on => :create
  validates :stop_number, uniqueness: { scope: :plivo_number }
end
