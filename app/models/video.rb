class Video < ActiveRecord::Base
  #validates_presence_of :title
  scope :finished, :conditions => { :encoded_state => "finished" }


  has_attached_file :video, 
  :url => "videos/:id.:basename.:extension",
  :path => "videos/:id.:basename.:extension",
  :storage => :s3
  #validates_attachment_presence :video
  has_attached_file :thumbnail, :styles => {:thumb => "162x161#"}

  attr_accessible :org_id, :owner_id, :video_id, :video_url, :video_host, :thumb_url, :video_duration

  after_destroy :remove_encoded_video

  # this runs on the after_destroy callback.  It is reponsible for removing the encoded file
  # and the thumbnail that is associated with this video.  Paperclip will automatically remove the other files, but
  # since we created our own bucket for encoded video, we need to handle this part ourselves.
  def remove_encoded_video
    unless output_url.blank?
      AWS::S3::Base.establish_connection!(
      :access_key_id     => zencoder_setting["s3_output"]["access_key_id"],
      :secret_access_key => zencoder_setting["s3_output"]["secret_access_key"]
      )
      AWS::S3::S3Object.delete(File.basename(output_url), zencoder_setting["s3_output"]["bucket"])
      # there is no real concept of folders in S3, they are just labels, essentially
      AWS::S3::S3Object.delete("/thumbnails_#{self.id}/frame_0000.png", zencoder_setting["s3_output"]["bucket"])
    end
  end

  # commence encoding of the video.  Width and height are hard-coded into this, but there may be situations where
  # you want that to be more dynamic - that modification will be trivial.
  def encode!(options = {})
    begin
      zen = Zencoder.new(
        "s3://" + zencoder_setting["s3_output"]["bucket"] + "/videos/", 
         zencoder_setting["settings"]["notification_url"],
         "http://s3.amazonaws.com/" + zencoder_setting["s3_output"]["bucket"] + "/thumbnails"
      )
      # 'video.url(:original, false)' prevents paperclip from adding timestamp, which causes errors
      #if zen.encode(self.video.url(:original, false), 800, 450, "/thumbnails_#{self.id}", options)
      #  self.encoded_state = "queued"
      #  self.output_url = zen.output_url
      #  self.job_id = zen.job_id
      #  self.save
      #else
      #  errors.add_to_base(zen.errors)
      #  nil
      #end
      #response = Zencoder::Job.create({ :input => "s3://" + zencoder_setting["s3_input"]["bucket"] + "/" + self.id.to_s + "." + self.video_file_name })
      #zen = Zencoder::Job.create({ 
      #  :input => "s3://coffeemobile_development/videos/" + self.id.to_s + "." + self.video_file_name,
      #  :outputs => [{ 
      #    :label => self.video_file_name, 
      #    :url => "s3://coffeemobile_encoded/videos/" + self.id.to_s + ".mp4"
      #  }]
      #})
      if zen.encode(self.video.url(:original, false), 1280, 720, "/thumbnails_#{self.id}", options)
        self.encoded_state = "queued"
        self.output_url = zen.output_url
        self.video_url = zen.output_url
        self.job_id = zen.job_id
        self.video_host = 1
        self.save
      else
        errors[:base] << zen.errors
        #errors.add_to_base(zen.errors)
        nil
      end
    rescue RuntimeError => exception
      errors.add_to_base("Video encoding request failed with result: " + exception.to_s)
      nil
    end
  end

  # must be called from a controller action, in this case, videos/encode_notify, that will capture the post params
  # and send them in.  This captures a successful encoding and sets the encode_state to "finished", so that our application
  # knows we're good to go.  It also retrieves the thumbnail image that Zencoder creates and attaches it to the video
  # using Paperclip.  And finally, it retrieves the duration of the video, again from Zencoder.
  def capture_notification(output)
    self.encoded_state = output[:state]
    if self.encoded_state == "finished"
      self.video_host = 1
      self.output_url = output[:url]
      self.video_url = output[:url]
      begin
        self.thumbnail = open(URI.parse("http://s3.amazonaws.com/" + zencoder_setting["s3_output"]["bucket"] + "/thumbnails/thumbnails_#{self.id}/frame_0000.png"))
        self.thumb_url = "http://s3.amazonaws.com/" + zencoder_setting["s3_output"]["bucket"] + "/thumbnails/thumbnails_#{self.id}/frame_0000.png"
      rescue
        self.thumb_url = "http://dashboard.coffeemobile.com/coffee-badge.png"
      ensure
        Rails.logger.debug("http://s3.amazonaws.com/" + zencoder_setting["s3_output"]["bucket"] + "/thumbnails/thumbnails_#{self.id}/frame_0000.png")
      end
      begin
        Rails.logger.debug("Attempting to find the post with attached object")
        @attachment = Attachment.where(:json => "{\"objects\":[{\"source\":6, \"source_id\":#{self.id}}]}").first
        @post = Post.where(:attachment_id => @attachment[:id]).first
        @post.update_attribute(:is_valid, true)
      rescue

      ensure
        Rails.logger.debug("Failed to do this")
      end
      self.thumbnail_content_type = "image/png"
      # get the job details so we can retrieve the length of the video in milliseconds
      zen = Zencoder.new
      temp = zen.details(self.job_id)["job"]["output_media_files"].first["duration_in_ms"]
      self.video_duration = temp.to_i / 1000
    end
    self.save
  end

  # a handy way to turn duration_in_ms into a formatted string like 5:34
  def human_length
    if duration_in_ms
      minutes = duration_in_ms / 1000 / 60
      seconds = (duration_in_ms / 1000) - (minutes * 60)
      sprintf("%d:%02d", minutes, seconds)
    else
      "Unknown"
    end
  end

  private

  def zencoder_setting
    @zencoder_config ||= YAML.load_file("#{Rails.root}/config/zencoder.yml")
  end

end