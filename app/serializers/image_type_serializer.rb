class ImageTypeSerializer < ActiveModel::Serializer
  attributes :description, 
  :allow_comments, 
  :allow_likes,
  :allow_flags,
  :allow_delete,
  :allow_enlarge
end
