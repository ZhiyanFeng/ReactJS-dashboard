class UserGroupSerializer < ActiveModel::Serializer
  has_one :avatar_image, serializer: ProfileImageSerializer
  attributes :id,
  :member_count,
  :group_name,
  :group_description,
  :attachment
  
  def member_count
    User.where(:user_group => object.id).count
  end

  def id
    if object.id.presence
      object.id
    else
      0
    end
  end

  def attachment
    if object.group_avatar_id.presence
      @attachments = Attachment.find(object.group_avatar_id)
      @attachments.to_objs
    end
  end
end
