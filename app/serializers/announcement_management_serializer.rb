class AnnouncementManagementSerializer < ActiveModel::Serializer  
  attributes :id,
  :org_id,
  :title,
  :content,
  :views_count,
  :comments_count,
  :likes_count,
  :views_count,
  :user_group,
  :location,
  :liked,
  :flagged,
  :created_at,
  :sorted_at,
  :attachment,
  :settings,
  :organization

  def location_id
    object.location
  end
  
  def attachment
    if object.attachment_id.presence
      @attachments = Attachment.find(object.attachment_id)
      @attachments.to_objs      
    end
  end
  
  def liked
    result = false
    if object.likes.presence
      object.likes.each do |l|
        if l.owner_id.to_s == object.user_id.to_s
          result = true
          result
        end
      end
    end
    result
  end
  
  def flagged
    result = false
    if object.flags.presence
      object.flags.each do |l|
        if l.owner_id.to_s == object.user_id.to_s
          result = true
          result
        end
      end
    end
    result
  end
  
  def settings
    PostSettingsSerializer.new(object.settings)
  end
  
  def organization
    OwnerOrganizationSerializer.new(object.organization)
  end
end
