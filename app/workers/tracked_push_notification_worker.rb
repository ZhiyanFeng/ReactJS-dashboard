class TrackedPushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(user_id,user_first_name,user_last_name,user_push_to,user_push_id,post_id,post_content,post_channel_id,cpr_id,post_archtype,base_type)
    response = 0
    if post_archtype
      message = "#{user_first_name} #{user_last_name} posted a shift trade request. Interested in helping out?"
      response = tracked_subscriber_push("open_app", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "announcement"
      message = user_first_name + " " + user_last_name + " announced: " + post_content
      response = tracked_subscriber_push("open_detail", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "post"
      message = user_first_name + " " + user_last_name + " posted: " + post_content
      response = tracked_subscriber_push("open_detail", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "training"
      message = user_first_name + " " + user_last_name + " posted a training: " + post_title
      response = tracked_subscriber_push("open_training", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "schedule"
      if post_content.present?
        message = post_content
      else
        message = user_first_name + " " + user_last_name + " posted a schedule"
      end
      response = tracked_subscriber_push("open_app", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "quiz"
      message = user_first_name + " " + user_last_name + " posted a quiz: " + post_title
      response = tracked_subscriber_push("open_quiz", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "shift"
      message = "#{user_first_name} #{user_last_name} posted a shift trade request. Interested in helping out?"
      response = tracked_subscriber_push("open_app", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    else
      message = user_first_name + " " + user_last_name + " posted: " + post_content
      response = tracked_subscriber_push("open_app", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    end
    if response == 1
      cpr.update_attributes(:attempted => cpr[:attempted] + 1, :success => cpr[:success] + 1)
    elsif response == -1
      cpr.update_attributes(:attempted => cpr[:attempted] + 1, :failed_due_to_other => cpr[:failed_due_to_other] + 1)
    elsif response == -2
      cpr.update_attributes(:attempted => cpr[:attempted] + 1, :failed_due_to_missing_id => cpr[:failed_due_to_missing_id] + 1)
    end
  end

  def tracked_subscriber_push(action, message, source=nil, source_id=nil, user_object=nil, channel_id, push_to, push_id)
    user_object.update_attribute(:push_count, user_object[:push_count] + 1)
    if push_to == "GCM"
      begin
        n = Rpush::Gcm::Notification.new
        n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
        n.registration_ids = push_id
        if channel_id > 0
          n.data = {
            :action => action, # Take out in future
            :category => action, # Take out in future
            :cat => action,
            :message => message, # Take out in future
            :msg => message,
            :org_id => 1, # Take out in future
            :oid => 1,
            :source => source, # Take out in future
            :source_id => source_id, # Take out in future
            :sid => source_id,
            :channel_id => channel_id, # Take out in future
            :cid => channel_id
          }
          n.save!
          return 1
        end
      rescue Exception => error
        ErrorLog.create(
          :file => "rb",
          :function => "tracked_subscriber_push",
          :error => "Unable to push to gcm: #{error}")
        if error.includes? "Device token is invalid"
          return -1
        else
          return -2
        end
      end
    end

    if push_to == "APNS"
      begin
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
        n.device_token = push_id
        n.alert = message.truncate(100)
        n.badge = user_object[:push_count]
        n.data = {
          :act => action, # Take out in future
          :cat => action,
          :oid => 1,
          :src => source,
          :sid => source_id
        }
        n.save!
        return 1
      rescue Exception => error
        ErrorLog.create(
          :file => "rb",
          :function => "tracked_subscriber_push",
          :error => "Unable to push to apns: #{error}")
        if error.includes? "Device token is invalid"
          return -1
        else
          return -2
        end
      end
    end
  end

end
