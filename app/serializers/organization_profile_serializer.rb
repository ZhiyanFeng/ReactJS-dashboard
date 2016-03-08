class OrganizationProfileSerializer < ActiveModel::Serializer
  has_one :profile_image, serializer: ProfileImageSerializer
  has_one :cover_image, serializer: CoverImageSerializer
  has_many :gallery_image
  attributes :id, 
  :name,
  :address,
  :city, 
  :province,
  :country,
  :status
end
