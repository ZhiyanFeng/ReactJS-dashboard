class ImageSettingsSerializer < ActiveModel::Serializer
  self.root = false
  attributes :description, 
  :allow_comments, 
  :allow_likes,
  :allow_flags,
  :allow_delete,
  :allow_enlarge
end
