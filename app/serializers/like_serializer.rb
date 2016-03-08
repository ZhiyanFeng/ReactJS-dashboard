class LikeSerializer < ActiveModel::Serializer
  attributes :owner_id,
  :owner, 
  :source_id,
  :source_table,
  :created_at
  
  def source_table
    Source.name_from_id(object.source)
  end
  
  def owner
    OwnerSerializer.new(object.owner)
  end
end
