# == Schema Information
#
# Table name: attachments
#
#  id   :integer          not null, primary key
#  json :string(255)
#

class Attachment < ActiveRecord::Base
	attr_accessible :json
	attr_accessor :images, :videos, :events, :schedules, :safety_courses, :file_uploads
	validates_presence_of :json, :on => :create

  def to_objs
    objs = []
    count = 0
    begin
      objArray = JSON.parse(self.json)
      objArray["objects"].each do |p|
        if p["source"] == 3
          if Image.exists?(:id => p["source_id"])
            obj = Image.find(p["source_id"])
            objs.insert(count, ImageAttachmentSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 6
          if Video.exists?(:id => p["source_id"])
            obj = Video.find(p["source_id"])
            objs.insert(count, VideoSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 7
          if Event.exists?(:id => p["source_id"])
            obj = Event.find(p["source_id"])
            objs.insert(count, EventSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 8
          if Poll.exists?(:id => p["source_id"])
            obj = Poll.find(p["source_id"])
            objs.insert(count, PollPostSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 9
          if SafetyCourse.exists?(:id => p["source_id"])
            obj = SafetyCourse.find(p["source_id"])
            objs.insert(count, SafetyCourseSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 10
          if FileUpload.exists?(:id => p["source_id"])
            obj = FileUpload.find(p["source_id"])
            objs.insert(count, FileUploadSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 11
          if ScheduleElement.exists?(:id => p["source_id"])
            obj = ScheduleElement.find(p["source_id"])
            objs.insert(count, ShiftSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 12
          if Schedule.exists?(:id => p["source_id"])
            obj = Schedule.find(p["source_id"])
            objs.insert(count, ScheduleSerializer.new(obj))
            count = count + 1
          end
        else
        end
      end
    rescue
    ensure
    end
    return objs
  end

  def to_objs_mobile(user_id)
    objs = []
    count = 0
    begin
      objArray = JSON.parse(self.json)
      objArray["objects"].each do |p|
        if p["source"] == 3
          if Image.exists?(:id => p["source_id"])
            obj = Image.find(p["source_id"])
            objs.insert(count, ImageAttachmentSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 6
          if Video.exists?(:id => p["source_id"])
            obj = Video.find(p["source_id"])
            objs.insert(count, VideoSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 7
          if Event.exists?(:id => p["source_id"])
            obj = Event.find(p["source_id"])
            objs.insert(count, EventSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 8
          if Poll.exists?(:id => p["source_id"])
            obj = Poll.find(p["source_id"])
            obj.set_user(user_id)
            objs.insert(count, PollPostMobileSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 9
          if SafetyCourse.exists?(:id => p["source_id"])
            obj = SafetyCourse.find(p["source_id"])
            objs.insert(count, SafetyCourseSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 10
          if FileUpload.exists?(:id => p["source_id"])
            obj = FileUpload.find(p["source_id"])
            objs.insert(count, FileUploadSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 11
          if ScheduleElement.exists?(:id => p["source_id"])
            obj = ScheduleElement.find(p["source_id"])
            objs.insert(count, ShiftSerializer.new(obj))
            count = count + 1
          end
        elsif p["source"] == 12
          if Schedule.exists?(:id => p["source_id"])
            obj = Schedule.find(p["source_id"])
            objs.insert(count, ScheduleSerializer.new(obj))
            count = count + 1
          end
        else
        end
      end
    rescue
    ensure
    end
    return objs
  end

  def parent
    if Post.exists?(:attachment_id => self[:id])
      Post.where(:attachment_id => self[:id]).first
    else
      nil
    end
  end
end
