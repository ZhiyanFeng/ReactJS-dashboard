class PostSerializer < ActiveModel::Serializer
  attributes :id,
  :org_id,
  :title,
  :content,
  :comments_count,
  :likes_count,
  :views_count,
  :created_at,
  :attachment,
  :user_group,
  :location,
  :settings,
  :owner_id,
  :owner,
  :is_valid
  
  def location_id
    object.location
  end

  def attachment
    if object.attachment_id.presence
      @attachments = Attachment.find(object.attachment_id)
      @attachments.to_objs
    end
  end
  
  def organization
    if Organization.exist?(object.org_id)
      @organization = OrganizationProfileSerializer.new(Organization.find(object.org_id))
    else
      object.org_id
    end
  end

  def settings
    PostSettingsSerializer.new(object.settings)
  end
  
  def owner
    OwnerSerializer.new(object.owner)
  end

end
