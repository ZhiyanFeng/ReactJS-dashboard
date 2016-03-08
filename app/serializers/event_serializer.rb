class EventSerializer < ActiveModel::Serializer
  self.root = "event"
  attributes :id,
  :event_start,
  :event_end,
  :event_poi,
  :event_address,
  :event_lat,
  :event_lng
end
