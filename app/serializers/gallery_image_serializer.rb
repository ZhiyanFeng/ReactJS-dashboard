class GalleryImageSerializer < ActiveModel::Serializer
  #has_one :owner
  #has_one :settings
  #has_many :comments
  attributes :id, 
  :owner_id, 
  :comments_count,
  :likes_count,
  :thumb_url,
  :gallery_url,
  :full_url,
  :liked,
  :flagged,
  :comments,
  :created_at
  
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
  
  def comments    
    if object.comments.presence
      #ActiveModel::ArraySerializer.new(object.comments, each_serializer: CommentSerializer)
      object.comments.map do |comment|
        CommentSerializer.new(comment, scope: scope, root: false)
      end
    end
  end
end
