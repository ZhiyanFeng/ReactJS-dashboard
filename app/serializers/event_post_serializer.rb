class EventPostSerializer < ActiveModel::Serializer
  has_one :settings
  has_one :organization
  attributes :id,
  :org_id,
  :title,
  :content,
  :comments_count,
  :likes_count,
  :liked,
  :flagged,
  :created_at,
  :attachment
  
  def attachment
    if object.attachment_id.presence
      @attachments = Attachment.find(object.attachment_id)
      @attachments.to_objs
    end
  end
end