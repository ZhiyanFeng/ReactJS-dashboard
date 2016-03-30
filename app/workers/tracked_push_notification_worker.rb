class TrackedPushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(user,post,cpr_id,post_archtype,base_type)
    response = 0
    if post_archtype
      message = "#{user[:first_name]} #{user[:last_name]} posted a shift trade request. Interested in helping out?"
      response = user.mession.tracked_subscriber_push("open_app", message, 4, post[:id], user[:id], post[:channel_id])
    elsif base_type == "announcement"
      message = user[:first_name] + " " + user[:last_name] + " announced: " + post[:content]
      response = user.mession.tracked_subscriber_push("open_detail", message, 4, post[:id], user[:id], post[:channel_id])
    elsif base_type == "post"
      message = user[:first_name] + " " + user[:last_name] + " posted: " + post[:content]
      response = user.mession.tracked_subscriber_push("open_detail", message, 4, post[:id], user[:id], post[:channel_id])
    elsif base_type == "training"
      message = user[:first_name] + " " + user[:last_name] + " posted a training: " + post_title
      response = user.mession.tracked_subscriber_push("open_training", message, 4, post[:id], user[:id], post[:channel_id])
    elsif base_type == "schedule"
      if post[:content].present?
        message = post[:content]
      else
        message = user[:first_name] + " " + user[:last_name] + " posted a schedule"
      end
      response = user.mession.tracked_subscriber_push("open_app", message, 4, post[:id], user[:id], post[:channel_id])
    elsif base_type == "quiz"
      message = user[:first_name] + " " + user[:last_name] + " posted a quiz: " + post_title
      response = user.mession.tracked_subscriber_push("open_quiz", message, 4, post[:id], user[:id], post[:channel_id])
    elsif base_type == "shift"
      message = "#{user[:first_name]} #{user[:last_name]} posted a shift trade request. Interested in helping out?"
      response = user.mession.tracked_subscriber_push("open_app", message, 4, post[:id], user[:id], post[:channel_id])
    else
      message = user[:first_name] + " " + user[:last_name] + " posted: " + post[:content]
      response = user.mession.tracked_subscriber_push("open_app", message, 4, post[:id], user[:id], post[:channel_id])
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
