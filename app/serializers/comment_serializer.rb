class CommentSerializer < ActiveModel::Serializer
  self.root = nil
  attributes :id, 
  :content, 
  :likes_count,
  :liked,
  :flagged,
  :created_at,
  :owner
  
  def owner
    OwnerSerializer.new(object.owner)
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
end
