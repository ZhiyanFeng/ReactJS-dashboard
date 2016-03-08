class Schedule < ActiveRecord::Base
  has_many :schedule_elements, -> { where ['schedule_elements.is_valid'] }, :class_name => "ScheduleElement", :foreign_key => "schedule_id"
  
  # To specify the columns to use call it like this:
  # 
  # has_event_calendar :start_at_field  => 'custom_start_at', :end_at_field => 'custom_end_at'
  #
  
  attr_accessible :name, 
  :org_id, 
  :location_id, 
  :start_date, 
  :end_date, 
  :admin_id, 
  :shift_trade, 
  :trade_authorization,
  :snapshot_url,
  :is_valid

end