class PostSignupWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(user_id, mession_id)
    #Rails.logger.debug "PostSignupWorker mession_id #{mession_id} user_id #{user_id}"
    if User.exists?(:id => user_id)
      @user = User.find(user_id)
      if UserPrivilege.exists?(:owner_id => user_id, :is_valid => true)
        @user_first_location = UserPrivilege.where(:owner_id => user_id, :is_valid => true).first

        count = UserPrivilege.where(:location_id => @user_first_location[:location_id], :is_valid => true).count

        message_body = "Hello"

        if mession_id.to_i == 0
          Rails.logger.debug "mession_id is 0"
          #if Mession.exists?(:user_id => user_id, :is_active => true)
          if Mession.exists?(["user_id = ? AND is_active AND push_id IS NOT NULL", user_id])
            #mession_id = Mession.where(:user_id => user_id, :is_active => true).pluck(:id).first
            mession_id = Mession.where(["user_id = ? AND is_active AND push_id IS NOT NULL", user_id]).order("created_at DESC").pluck(:id).first
            #Rails.logger.debug "PostSignupWorker new mession_id found #{mession_id}"
          else
            mession_id = 0
          end
        else
          Rails.logger.debug "mession_id is not 0"
        end

        if mession_id > 0
          action = "none"
          if count == 1
            message_body = "You're kinda the only one in your network #{@user[:first_name]}. Be your locations champ by using this link to invite your team to Shyft!"
            action = "contact_invite"
          elsif count <= 3
            message_body = "Nice work #{@user[:first_name]}, you're already at #{count} team members in your location. Remember, the more team members you invite, the more co-workers you can Shyft with!"
            action = "contact_invite"
          elsif count <= 6
            message_body = "Good job #{@user[:first_name]}, your network has stepped up to #{count} users. Missing anyone? Keep up the solid Shyfting by inviting here: Use this link if you're missing anyone that needs Shyft:"
            action = "contact_invite"
          else
            if !@user[:profile_id].present?
              message_body = "Hi #{@user[:first_name]}! Remember to upload a profile pic on Shyft, so your team members know how strong your selfie game is. This link will take you there: "
              action = "profile"
            else
              @channels = Subscription.where(:user_id => @user[:id], :is_valid => true, :is_active => true)
              channel_id_list = @channels.pluck(:id)
              if Post.exists?("channel_id in (#{channel_id_list.join(",")}) AND is_valid = 't' AND post_type = 19")
                message_body = "Awesome job #{@user[:first_name]}! Your network has stepped up to #{count} users. Nice Shyfting! Missing anyone though? Use this link to get them on Shyft"
                action = "contact_invite"
              else
                message_body = "Awesome job #{@user[:first_name]}! You guys are already at #{count} team members in your location. Use this quick link to share this weeks schedule"
                action = "create_schedule"
              end
            end
          end
          #mession exists send maybe push
          @mession = Mession.find(mession_id)
          @mession.push_no_content(message_body, action)
        else
          if count == 1
            #message_body = "You are kinda the only one in your network #{@user[:first_name]}! Be your locations champ and invite your team to start Shyfting. http://bit.ly/1OL7WxZ"
            message_body = "Hey #{@user[:first_name]}! ShyftBot here👋 ... So you're kinda the only one in your network - and you kinda need your team on the app for this whole thing to work out. Be the hero and use this link to get your team on Shyft http://bit.ly/1OL7WxZ";
          elsif count <= 3
            #message_body = "Nice work #{@user[:first_name]}, you are already at #{count} users on your network. Remember, more team members you invite, the more co-workers you can Shyft with! http://bit.ly/1OL7WxZ"
            message_body = "Solid work #{@user[:first_name]}, you've grown your team to  #{count} members👌 Sometimes people need a little extra nudge though, use this link if you're missing any coworkers on Shyft http://bit.ly/1OL7WxZ"
          elsif count <= 6
            #message_body = "Good job #{@user[:first_name]}, your network has stepped up to #{count} users. Missing anyone? Keep up the solid Shyfting by inviting here: http://bit.ly/1OL7WxZ"
            message_body = "Boom! Your network has grown to #{count} team members. My job is to help get your whole team on the app so you can have a cool app for work! This link lets invite your last few team members http://bit.ly/1OL7WxZ"
          else
            if !@user[:profile_id].present?
              #message_body = "Hey #{@user[:first_name]}. Remember to upload a profile pic on Shyft, so your team members know how strong your selfie game is. This link will take you there: http://bit.ly/1TSRQDu"
              message_body = "Hi #{@user[:first_name]}! Remember to upload a profile pic on Shyft, so your team members know how strong your selfie game is. This link will take you there http://bit.ly/1TSRQDu"
            else
              @channels = Subscription.where(:user_id => @user[:id], :is_valid => true, :is_active => true)
              channel_id_list = @channels.pluck(:id)
              if Post.exists?("channel_id in (#{channel_id_list.join(",")}) AND is_valid = 't' AND post_type = 19")
                #message_body = "Awesome job #{@user[:first_name]}! You guys are already at #{count} team members in your location. Missing anyone though? Invite them to Shyft here: http://bit.ly/1OL7WxZ"
                message_body = "Hey, its me again. Awesome job #{@user[:first_name]}! Since your network has stepped up to #{count} users, it might make sense to add a schedule? You can do that here: http://bit.ly/1OL7WxZ"
              else
                #message_body = "Awesome job #{@user[:first_name]}! You have #{count} coworkers in your network. There is no schedule though, use this link to change that: http://bit.ly/1I53bzK"
                message_body = false
              end
            end
          end
          if message_body
            #mession does not exists, maybe sms?
            t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
            t_token = '81eaed486465b41042fd32b61e5a1b14'

            @client = Twilio::REST::Client.new t_sid, t_token

            #phone_number = @user[:phone_number].gsub(/[\+\-\(\)\s]/,'')
            phone_number = @user[:phone_number].gsub(/\W/,'')
            begin
              message = @client.account.messages.create(
                :body => message_body,
                #:to => "+"+@user[:phone_number],
                :to => phone_number.size > 10 ? "+"+ phone_number : phone_number,
                :from => "+16473602178"
              )
            rescue Twilio::REST::RequestError => e
              ErrorLog.create(
                :file => "post_signup_worker.rb",
                :function => "perform",
                :error => "#{e}")
            end
          end
        end
      else
        ErrorLog.create(
          :file => "post_signup_worker.rb",
          :function => "perform",
          :error => "PostSignupWorker cannot find active user_privileges for user with id #{user_id}")
      end
    else
      ErrorLog.create(
        :file => "post_signup_worker.rb",
        :function => "perform",
        :error => "PostSignupWorker cannot find user with id #{user_id}")
    end

  end
end
