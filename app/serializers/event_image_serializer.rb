class EventImageSerializer < ActiveModel::Serializer
  self.root = "image"
  has_one :settings
  attributes :id, 
  :comments_count,
  :likes_count,
  :thumb_url,
  :gallery_url,
  :full_url
end
