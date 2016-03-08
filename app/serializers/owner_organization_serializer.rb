class OwnerOrganizationSerializer < ActiveModel::Serializer
  has_one :profile_image, serializer: ProfileImageSerializer
  self.root = false
  attributes :id,
  :name
  #:name, 
  #:profile_image
  
  #def profile_image
  #  ProfileImageSerializer.new(object.profile_image)
  #end
end
