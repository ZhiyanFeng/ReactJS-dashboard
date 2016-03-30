class TrackedPushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(user_id,mession_id,post_id,post_content,post_channel_id,poster_name,cpr_id,post_archtype,base_type)
    response = 0
    @user = User.find(user_id)
    @mession = Mession.find(mession_id)
    cpr = ChannelPushReport.find(cpr_id)
    if post_archtype
      message = "#{poster_name} posted a shift trade request. Interested in helping out?"
      response = @mession.tracked_subscriber_push("open_app", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "announcement"
      message = poster_name + " announced: " + post_content
      response = @mession.tracked_subscriber_push("open_detail", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "post"
      message = poster_name + " posted: " + post_content
      response = @mession.tracked_subscriber_push("open_detail", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "training"
      message = poster_name + " posted a training: " + post_title
      response = @mession.tracked_subscriber_push("open_training", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "schedule"
      if post_content.present?
        message = post_content
      else
        message = poster_name + " posted a schedule"
      end
      response = @mession.tracked_subscriber_push("open_app", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "quiz"
      message = poster_name + " posted a quiz: " + post_title
      response = @mession.tracked_subscriber_push("open_quiz", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "shift"
      message = "#{poster_name} posted a shift trade request. Interested in helping out?"
      response = @mession.tracked_subscriber_push("open_app", message, 4, post_id, @user, post_channel_id, @mession)
    else
      message = poster_name + " posted: " + post_content
      response = @mession.tracked_subscriber_push("open_app", message, 4, post_id, @user, post_channel_id, @mession)
    end
    if response == 1
      cpr.update_attributes(:attempted => cpr[:attempted] + 1, :success => cpr[:success] + 1)
    elsif response == -1
      cpr.update_attributes(:attempted => cpr[:attempted] + 1, :failed_due_to_other => cpr[:failed_due_to_other] + 1)
    elsif response == -2
      cpr.update_attributes(:attempted => cpr[:attempted] + 1, :failed_due_to_missing_id => cpr[:failed_due_to_missing_id] + 1)
    else
      cpr.update_attributes(:attempted => cpr[:attempted] + 1, :failed_due_to_other => cpr[:failed_due_to_other] + 1)
    end
  end

end
