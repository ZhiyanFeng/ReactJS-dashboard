class UserSimpleSerializerV2 < ActiveModel::Serializer
  self.root = false
  attributes :id,
  :first_name,
  :last_name,
  :profile_image,
  :cover_image

  def id
    object.id
  end

  def first_name
    object.first_name
  end

  def last_name
    object.last_name
  end

  def profile_image
    ProfileImageSerializer.new(object.profile_image)
  end

  def cover_image
    ProfileImageSerializer.new(object.cover_image)
  end
end
