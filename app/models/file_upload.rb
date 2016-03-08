class FileUpload < ActiveRecord::Base
	belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"

	attr_accessible :pdf, :org_id, :owner_id, :file_location_url, :upload_file_name, :upload_content_type, :upload_file_size, :upload_updated_at

	has_attached_file :upload, :path =>  "/files/:id_:basename.:extension" 
	validates_attachment :upload, :content_type => { :content_type => %w(application/pdf application/msword 
    application/vnd.openxmlformats-officedocument.wordprocessingml.document 
    application/vnd.openxmlformats-officedocument.wordprocessingml.template 
    application/vnd.openxmlformats-officedocument.spreadsheetml.template 
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet 
    application/vnd.openxmlformats-officedocument.presentationml.slide 
    application/vnd.openxmlformats-officedocument.presentationml.presentation 
    application/vnd.openxmlformats-officedocument.presentationml.slideshow 
    application/vnd.openxmlformats-officedocument.presentationml.template) }

	after_save :process_file

	def process_file
		if self.upload.present?
	    PdfUploadWorker.perform_async(id, key) if key.present?
	  end
  end

  def check_file(file)
  	Rails.logger.debug(file.inspect)
  	#if file.content_type == "application/pdf"
    if file
    	#self.update_attribute = file
    	self.update_attribute(:upload, file)
    	#self.update_attribute(:file_location_url, "http://s3.amazonaws.com/" + Paperclip::Attachment.default_options[:url] + "/pdf/#{self.id}_#{self.upload_file_name}")
    	self.update_attribute(:file_location_url, upload.url)
    	#http://s3.amazonaws.com/" + zencoder_setting["s3_output"]["bucket"] + "/thumbnails/
    #elsif file.content_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      #self.update_attribute = file
      #self.update_attribute(:upload, file)
      #self.update_attribute(:file_location_url, "http://s3.amazonaws.com/" + Paperclip::Attachment.default_options[:url] + "/pdf/#{self.id}_#{self.upload_file_name}")
      #self.update_attribute(:file_location_url, upload.url)
      #http://s3.amazonaws.com/" + zencoder_setting["s3_output"]["bucket"] + "/thumbnails/
    end
  end
end
