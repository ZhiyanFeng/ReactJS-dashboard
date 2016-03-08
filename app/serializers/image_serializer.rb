class ImageSerializer < ActiveModel::Serializer
  self.root = "image"
  #has_one :settings
  attributes :id, 
  :owner_id, 
  :comments_count,
  :likes_count,
  :thumb_url,
  :gallery_url,
  :full_url,
  :liked,
  :flagged,
  :created_at,
  :settings
  
  def settings
    ImageSettingsSerializer.new(object.settings)
  end
  
  def owner
    OwnerSerializer.new(object.owner)
  end
end
