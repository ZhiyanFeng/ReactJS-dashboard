class OwnerSerializer < ActiveModel::Serializer
  #has_one :profile_image, serializer: ProfileImageSerializer
  self.root = false
  attributes :id,
  :first_name, 
  :last_name,
  :profile_image
  
  def profile_image
    #Image.find(object.profile_id)
    ProfileImageSerializer.new(object.profile_image)
  end
end
