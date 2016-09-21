class SyncScheduleSerializerV2 < ActiveModel::Serializer
  attributes :id,
  :org_id,
  :type,
  :owner_id,
  :channel_id,
  :channel_name,
  :title,
  :content,
  :created_at,
  :updated_at,
  :attachment,
  :owner,
  :allow_delete,
  :is_valid

  def allow_delete
    if object.user_id.to_i == object.owner_id.to_i
      return true
    elsif Subscription.exists?(:user_id => object[:user_id], :is_admin => true, :channel_id => object[:channel_id], :is_valid => true)
      return true
    else
      return false
    end
  end

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

  def channel_name
    if Channel.exists?(:id => object.channel_id)
      @channel = Channel.find(object.channel_id)
      return @channel[:channel_name]
    end
  end

end