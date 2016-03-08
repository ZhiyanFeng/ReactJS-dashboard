class SafetyCourseSerializer < ActiveModel::Serializer
	self.root = "safety_course"
  attributes :id,
  :title, 
  :url, 
  :icon, 
  :size, 
  :folder, 
  :version
end