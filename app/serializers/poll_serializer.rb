class PollSerializer < ActiveModel::Serializer
  attributes :id,
  :org_id,
  :complete_count,
  :question_count
end
