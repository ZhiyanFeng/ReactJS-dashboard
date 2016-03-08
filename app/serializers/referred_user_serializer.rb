class ReferredUserSerializer < ActiveModel::Serializer

  attributes :id,
  :first_name, 
  :last_name,
  :profile_image,
  :created_at

  def id
    object.acceptor.id
  end

  def first_name
    object.acceptor.first_name
  end

  def last_name
    object.acceptor.last_name
  end

  def profile_image
    if object.acceptor.profile_id.present?
      ProfileImageSerializer.new(Image.find(object.acceptor.profile_id))
    else
      nil
    end
  end

  def created_at
    object.acceptor.created_at
  end
  
end
