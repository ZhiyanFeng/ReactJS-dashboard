class Event < ActiveRecord::Base
  has_event_calendar

  # To specify the columns to use call it like this:
  # 
  # has_event_calendar :start_at_field  => 'custom_start_at', :end_at_field => 'custom_end_at'
  #
  
  attr_accessible :name, :org_id, :owner_id, :start_at, 
    :end_at, :event_poi, :event_address, :event_lat, :event_lng, 
    :event_open, :is_valid 

end