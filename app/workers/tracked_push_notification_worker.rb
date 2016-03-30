class TrackedPushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(user_id,user_first_name,user_last_name,user_push_to,user_push_id,post_id,post_content,post_channel_id,cpr_id,post_archtype,base_type)
    response = 0
    if post_archtype
      message = "#{user_first_name} #{user_last_name} posted a shift trade request. Interested in helping out?"
      response = Mession.tracked_subscriber_push("open_app", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "announcement"
      message = user_first_name + " " + user_last_name + " announced: " + post_content
      response = Mession.tracked_subscriber_push("open_detail", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "post"
      message = user_first_name + " " + user_last_name + " posted: " + post_content
      response = Mession.tracked_subscriber_push("open_detail", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "training"
      message = user_first_name + " " + user_last_name + " posted a training: " + post_title
      response = Mession.tracked_subscriber_push("open_training", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "schedule"
      if post_content.present?
        message = post_content
      else
        message = user_first_name + " " + user_last_name + " posted a schedule"
      end
      response = Mession.tracked_subscriber_push("open_app", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "quiz"
      message = user_first_name + " " + user_last_name + " posted a quiz: " + post_title
      response = Mession.tracked_subscriber_push("open_quiz", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    elsif base_type == "shift"
      message = "#{user_first_name} #{user_last_name} posted a shift trade request. Interested in helping out?"
      response = Mession.tracked_subscriber_push("open_app", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    else
      message = user_first_name + " " + user_last_name + " posted: " + post_content
      response = Mession.tracked_subscriber_push("open_app", message, 4, post_id, user_id, post_channel_id, user_push_to, user_push_id)
    end
    if response == 1
      cpr.update_attributes(:attempted => cpr[:attempted] + 1, :success => cpr[:success] + 1)
    elsif response == -1
      cpr.update_attributes(:attempted => cpr[:attempted] + 1, :failed_due_to_other => cpr[:failed_due_to_other] + 1)
    elsif response == -2
      cpr.update_attributes(:attempted => cpr[:attempted] + 1, :failed_due_to_missing_id => cpr[:failed_due_to_missing_id] + 1)
    end
  end
end
