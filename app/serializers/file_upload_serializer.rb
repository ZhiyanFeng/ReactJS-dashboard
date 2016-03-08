class FileUploadSerializer < ActiveModel::Serializer
	self.root = "file"
  attributes :id,
  :file_location_url, 
  :upload_file_name, 
  :upload_content_type,
  :upload_file_size
end
