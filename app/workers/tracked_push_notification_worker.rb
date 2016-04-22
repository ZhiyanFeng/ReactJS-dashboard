class TrackedPushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(user_id,mession_id,post_id,post_content,post_channel_id,poster_name,cpr_id,post_archtype,base_type)
    response = 0
    @user = User.find(user_id)
    @mession = Mession.find(mession_id)
    if post_archtype
      #message = "#{poster_name} posted a shift trade request. Interested in helping out?"
      message = "Hey! #{poster_name} just posted a shift. Are you able to cover it 📆🔁🙋?"
      response = @mession.tracked_subscriber_push("open_app", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "announcement"
      #message = poster_name + " announced: " + post_content
      message = poster_name + " just posted an annoucnement. Let them know you read it by tapping the checkmark ✔️🙋"
      response = @mession.tracked_subscriber_push("open_detail", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "post"
      #message = poster_name + " just posted: " + post_content
      message = t('push.post') % {:name => poster_name, :content => post_content}
      response = @mession.tracked_subscriber_push("open_detail", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "training"
      message = poster_name + " posted a training: " + post_title
      response = @mession.tracked_subscriber_push("open_training", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "schedule"
      if post_content.present?
        #message = post_content
        #message = poster_name + " just posted a schedule"
        message = t('push.schedule') % {:name => poster_name}
      else
        #message = poster_name + " just posted a schedule"
        message = t('push.schedule') % {:name => poster_name}
      end
      response = @mession.tracked_subscriber_push("open_app", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "quiz"
      message = poster_name + " posted a quiz: " + post_title
      response = @mession.tracked_subscriber_push("open_quiz", message, 4, post_id, @user, post_channel_id, @mession)
    elsif base_type == "shift"
      message = "Hey! #{poster_name} just posted a shift. Are you able to cover it 📆🔁🙋?"
      response = @mession.tracked_subscriber_push("open_app", message, 4, post_id, @user, post_channel_id, @mession)
    else
      message = poster_name + " posted: " + post_content
      response = @mession.tracked_subscriber_push("open_app", message, 4, post_id, @user, post_channel_id, @mession)
    end
    if response == 1
      ChannelPushReport.increment_counter(:success,cpr_id)
      ChannelPushReport.increment_counter(:attempted,cpr_id)
    elsif response == 2
      ChannelPushReport.increment_counter(:failed_due_to_other,cpr_id)
      ChannelPushReport.increment_counter(:attempted,cpr_id)
    elsif response == 3
      ChannelPushReport.increment_counter(:failed_due_to_missing_id,cpr_id)
      ChannelPushReport.increment_counter(:attempted,cpr_id)
    else
      ChannelPushReport.increment_counter(:failed_due_to_other,cpr_id)
      ChannelPushReport.increment_counter(:attempted,cpr_id)
    end
  end

end
