class ImageAttachmentSerializer < ActiveModel::Serializer
  self.root = "image"
  attributes :id,
  :avatar_file_name,
  :avatar_file_size,
  :thumb_url,
  :gallery_url,
  :full_url

end
