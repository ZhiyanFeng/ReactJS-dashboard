class OwnerSerializerV2 < ActiveModel::Serializer
  #has_one :profile_image, serializer: ProfileImageSerializer
  self.root = false
  attributes :id,
  :first_name,
  :last_name,
  :profile_image,
  :cover_image

  def profile_image
    #Image.find(object.profile_id)
    ProfileImageSerializer.new(object.profile_image)
  end

  def cover_image
    #Image.find(object.profile_id)
    ProfileImageSerializer.new(object.cover_image)
  end
end
