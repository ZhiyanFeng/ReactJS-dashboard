class OrganizationSeekSerializer < ActiveModel::Serializer
	self.root = false
  has_one :profile_image, serializer: ProfileImageSerializer
  attributes :id, 
  :name, 
  :address, 
  :city,
  :country
end
