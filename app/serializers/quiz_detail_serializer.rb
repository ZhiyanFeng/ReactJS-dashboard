class QuizDetailSerializer < ActiveModel::Serializer
  attributes :id,
  :org_id,
  :completed,
  :attempts_count,
  :complete_count,
  :created_at,
  :questions
  
  def completed
    result = false

    result
  end
  
  def questions    
    if object.poll_questions.presence
      #ActiveModel::ArraySerializer.new(object.poll_questions, each_serializer: PollQuestionSerializer)
      object.poll_questions.map do |question|
        PollQuestionSerializer.new(question, scope: scope, root: false)
      end
    end
  end

end
