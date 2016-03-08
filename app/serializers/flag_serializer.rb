class FlagSerializer < ActiveModel::Serializer
  attributes :id, 
  :owner_id, 
  :source_id,
  :source_table
  
  def source_table
    Source.name_from_id(object.source)
  end
end
