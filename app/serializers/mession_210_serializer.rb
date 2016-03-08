class Mession210Serializer < ActiveModel::Serializer
  has_one :user
  attributes :id, :code, :message
  def code
    210
  end
  
  def message
    "Account does not belong to any org"
  end
end
