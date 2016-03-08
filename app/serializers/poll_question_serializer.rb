class PollQuestionSerializer < ActiveModel::Serializer
self.root = ""
  attributes :id,
  :question_type,
  :content,
  :attachment,
  :randomize,
  :answers
  
  def answers    
    if object.poll_answers.presence
      #ActiveModel::ArraySerializer.new(object.poll_answers, each_serializer: PollAnswerSerializer)
      object.poll_answers.map do |answer|
        PollAnswerSerializer.new(answer, scope: scope, root: false)
      end
    end
  end
  
  def attachment
    if object.attachment_id.presence
        @attachments = Attachment.find(object.attachment_id)
        @attachments.to_objs
    end
  end
end
