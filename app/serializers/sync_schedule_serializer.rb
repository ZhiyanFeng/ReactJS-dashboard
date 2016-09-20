class SyncScheduleSerializer < ActiveModel::Serializer
  attributes :id,
  :org_id,
  :type,
  :owner_id,
  :channel_id,
  :title,
  :content,
  :created_at,
  :updated_at,
  :attachment,
  :owner,
  :is_valid

  def attachment
    if object.attachment_id.presence
      @attachments = Attachment.find(object.attachment_id)
      @attachments.to_objs
    end
  end

  def type
    PostType.find_post_type(object.post_type)
  end

  def owner
    OwnerSerializer.new(object.owner)
  end

end
