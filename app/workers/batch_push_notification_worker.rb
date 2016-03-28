class BatchPushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(post_object)
    post_archtype = false
    if post_object.archtype.present? && post_object.archtype == "shift_trade"
      post_archtype = true
    end

    targets = User.joins(:subscription, :mession).where("subscriptions.channel_id = 1062 AND subscriptions.user_id != 1115 AND subscriptions.is_valid AND subscriptions.is_active AND messions.is_active AND subscriptions.subscription_mute_notifications = 'f'")

    targets.each do |user|

    end

    if User.exists?(:id => user_id)
      user = User.find(user_id)
      if Mession.exists?(:user_id => user_id, :is_active => true, :is_valid => true)
        @mession = Mession.where(:user_id => user_id, :is_active => true, :is_valid => true).first
        #action, message, source=nil, source_id=nil, sound=nil, badge=nil
        @user = User.find(post_owner_id)
        if post_archtype
          message = "#{@user[:first_name]} #{@user[:last_name]} posted a shift trade request. Interested in helping out?"
          @mession.subscriber_push("open_app", message, 4, post_id, nil, user)
        elsif base_type == "announcement"
          message = @user[:first_name] + " " + @user[:last_name] + " announced: " + post_content
          @mession.subscriber_push("open_detail", message, 4, post_id, nil, user)
        elsif base_type == "post"
          message = @user[:first_name] + " " + @user[:last_name] + " posted: " + post_content
          @mession.subscriber_push("open_detail", message, 4, post_id, nil, user)
        elsif base_type == "training"
          message = @user[:first_name] + " " + @user[:last_name] + " posted a training: " + post_title
          @mession.subscriber_push("open_training", message, 4, post_id, nil, user)
        elsif base_type == "schedule"
          if post_content.present?
            message = post_content
          else
            message = @user[:first_name] + " " + @user[:last_name] + " posted a schedule"
          end
          @mession.subscriber_push("open_app", message, 4, post_id, nil, user)
        elsif base_type == "quiz"
          message = @user[:first_name] + " " + @user[:last_name] + " posted a quiz: " + post_title
          @mession.subscriber_push("open_quiz", message, 4, post_id, nil, user)
        elsif base_type == "shift"
          message = "#{@user[:first_name]} #{@user[:last_name]} posted a shift trade request. Interested in helping out?"
          @mession.subscriber_push("open_app", message, 4, post_id, nil, user)
        else
          message = @user[:first_name] + " " + @user[:last_name] + " posted: " + post_content
          @mession.subscriber_push("open_app", message, 4, post_id, nil, user)
        end
      else
        ErrorLog.create(
          :file => "push_notification_worker.rb",
          :function => "perform",
          :error => "PushNotificationWorker cannot find valid messions for user with id #{user_id}")
      end
    else
      ErrorLog.create(
        :file => "push_notification_worker.rb",
        :function => "perform",
        :error => "PushNotificationWorker cannot find user with id #{user_id}")
    end
  end
end
