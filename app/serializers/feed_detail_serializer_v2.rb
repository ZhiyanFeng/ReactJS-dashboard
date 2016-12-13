class FeedDetailSerializerV2 < ActiveModel::Serializer
  #has_one :settings
  #has_one :owner
  #has_many :comments
  attributes :id,
  :channel_id,
  :title,
  :content,
  :liked,
  :flagged,
  :comments_count,
  :likes_count,
  :views_count,
  :allow_like,
  :allow_comment,
  :allow_delete,
  :created_at,
  :updated_at,
  :attachment,
  :owner,
  :owner_id,
  #:settings, taken out for v4
  :comments,
  :likes,
  :type

  def allow_delete
    if object.user_id.to_i == object.owner_id.to_i
      return true
    elsif Subscription.exists?(:user_id => object.user_id, :is_admin => true, :channel_id => object.channel_id, :is_valid => true)
      return true
    else
      return false
    end
  end

  def type
    PostType.find_post_type(object.post_type)
  end

  def attachment
    begin
      if object.attachment_id.presence
        @attachments = Attachment.find(object.attachment_id)
        @attachments.to_objs_v2(object.user_id)
      end
    rescue
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

  #def settings
  #  PostSettingsSerializer.new(object.settings)
  #end

  def owner
    OwnerSerializerV2.new(object.owner)
  end

  def comments
    if object.comments.presence
      #ActiveModel::ArraySerializer.new(object.comments, each_serializer: CommentSerializer)
      object.comments.map do |comment|
        CommentSerializer.new(comment, scope: scope, root: false)
      end
    end
  end

  def likes
    if object.likes.presence
      #ActiveModel::ArraySerializer.new(object.likes, each_serializer: LikeSerializer)
      object.likes.map do |like|
        LikeSerializer.new(like, scope: scope, root: false)
      end
    end
  end
end
