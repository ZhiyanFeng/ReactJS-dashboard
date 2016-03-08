class DashboardSafetyCourseSerializer < ActiveModel::Serializer
	self.root = "safety_course"
  attributes :id,
  :title, 
  :url, 
  :icon, 
  :size, 
  :folder, 
  :version,
  :attachment_id,
  :post_id

  def attachment_id
  	Attachment.where(['json like \'%"source":9, "source_id":?%\'', object.id]).pluck(:id).first
  end

  def post_id
    attachment_id = Attachment.where(['json like \'%"source":9, "source_id":?%\'', object.id]).pluck(:id).first
    Post.where(:org_id => object.check_this_org, :attachment_id => attachment_id).pluck(:id).first
  end
end