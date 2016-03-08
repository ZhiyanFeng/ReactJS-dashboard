class ChannelSubscribersSerializer < ActiveModel::Serializer
  attributes :id,
  :subscriber_id,
  :first_name,
  :last_name,
  :is_admin,
  :profile_image,
  :created_at,
  :updated_at,
  :is_valid

  def subscriber_id
    object.id
  end

  def is_admin
    object.is_admin
  end

  def id
    object.user.id
  end

  def first_name
    object.user.first_name
  end

  def last_name
    object.user.last_name
  end

  def profile_image
    ProfileImageSerializer.new(object.user.profile_image)
  end

  def created_at
    object.updated_at
  end
end
