class CoverImageSerializer < ActiveModel::Serializer
  self.root = false
  attributes :thumb_url, :gallery_url, :full_url
end
