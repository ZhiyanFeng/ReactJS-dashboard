class DashboardPollAnswerSerializer < ActiveModel::Serializer
  attributes :id,
  :content,
  :correct
  
  def correct
    object.correct
  end
end
