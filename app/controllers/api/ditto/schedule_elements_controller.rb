include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Ditto
    class ScheduleElementsController < ApplicationController
      class ScheduleElement < ::ScheduleElement
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end

      before_filter :restrict_access, :set_headers
      before_filter :fetch_schedule_element, :except => [:cleanup]

      respond_to :json

      def cleanup
        ShiftCleanupWorker.perform_async
        render json: { "code" => 1, "message" => "Shift deleted by owner." }
      end

      def fetch_schedule_element
        if ScheduleElement.exists?(:id => params[:id])
          @schedule_element = ScheduleElement.find_by_id(params[:id])
        end
      end

      def update_tip
        if Gratitude.exists?(:shift_id => params[:id], :is_valid => true)
          @tip = Gratitude.where(:shift_id => params[:id], :is_valid => true).first
          if @tip[:owner_id].to_i == params[:user_id].to_i
            if params[:tip_amount].to_i == 0
              @tip.update_attributes(:amount => params[:tip_amount], :is_valid => false)
            else
              @tip.update_attribute(:amount, params[:tip_amount])
            end
            #render json: { "eXpresso" => { "code" => 1, "message" => "The tip for this shift has been changed successfully." } }
            render json: @schedule_element, serializer: ShiftStandaloneSerializerSelfRoot
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, only the original tipper may edit the tip amount." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "There is no tip associated with this shift, unable to edit." } }
        end
      end

      #def tip
        #@post = Post.find(params[:post_id])
        #@gratitude = Gratitude.new(
        #  :amount => params[:amount],
        #  :owner_id => params[:user_id],
        #  :source => 4,
        #  :source_id => post[:id]
        #)
        #if @gratitude.create_gratitude
        #  @post.touch
        #  render json: { "code" => -188, "message" => "Shift deleted by owner." }
        #else
        #  render json: { "code" => -1, "message" => @schedule_element.errors }
        #end
      #end

      def cover
        @post = Post.find(params[:post_id])
        @post.touch
        @req = Channel.find(@post[:channel_id])

        result = @schedule_element.cover(params[:user_id], @req[:shift_trade_require_approval])
        if result == "success"
          if Mession.exists?(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:owner_id]])
            @coverer = User.find(params[:user_id])
            #@message = "Hey! " + @coverer[:first_name] + " " + @coverer[:last_name] + " just agreed to cover your shift, that was easy 👍"
            @message = I18n.t('push.shift.cover') % {:name => @coverer[:first_name] + " " + @coverer[:last_name]}
            #UserAnalytic.create(:action => 7, :org_id => @post[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
            mession = Mession.where(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:owner_id]]).first
            mession.target_push('open_app', @message, nil, @post[:id], 'silent.mp3', nil)
          end
          @schedule_element.check_user(params[:user_id])
          render json: @schedule_element, serializer: ShiftStandaloneSerializerSelfRoot
        elsif result == "pending"
          if Mession.exists?(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:owner_id]])
            @coverer = User.find(params[:user_id])
            #@message = "Hey! " + @coverer[:first_name] + " " + @coverer[:last_name] + " just agreed to cover your shift! Your manager has been notified to approve it 🙋"
            @message = I18n.t('push.shift.pending') % {:name => @coverer[:first_name] + " " + @coverer[:last_name]}
            #UserAnalytic.create(:action => 7, :org_id => @post[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
            mession = Mession.where(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:owner_id]]).first
            mession.target_push('open_app', @message, nil, nil, 'silent.mp3', nil)
          end
          @schedule_element.check_user(params[:user_id])
          render json: @schedule_element, serializer: ShiftStandaloneSerializerSelfRoot
        elsif result == "covered"
          render json: { "code" => -186, "message" => "Shift already covered by someone else." }
        elsif result == "deleted"
          render json: { "code" => -188, "message" => "Shift deleted by owner." }
        elsif result == "expired"
          render json: { "code" => -189, "message" => "The shift you are trying to cover has expired. If this is not correct please contact support@myshyft.com", "error" => "Trying to cover an expired shift." }
        else
          render json: { "code" => -1, "message" => @schedule_element.errors }
        end
      end

      def approve
        @post = Post.find(params[:post_id])
        @post.touch
        @req = Channel.find(@post[:channel_id])

        result = @schedule_element.approve(params[:user_id], @req[:shift_trade_require_approval])
        if result == "inapplicable"
          render json: { "code" => -1, "message" => "This location does not require shift trade approval.", "error" => "This location does not require shift trade approval."}
        elsif result == "deleted"
          render json: { "code" => -1, "message" => "This shift is already deleted by the poster.", "error" => "The status code of the shift is deleted."}
        elsif result == "uncovered"
          render json: { "code" => -1, "message" => "This shift has not yet been covered.", "error" => "The status code of the shift is not covered."}
        elsif result == "success"
          @poster = User.find(@schedule_element[:owner_id])
          @coverer = User.find(@schedule_element[:coverer_id])
          @approver = User.find(params[:user_id])
          if Mession.exists?(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:owner_id]])
            #@message = "Hey! " + @approver[:first_name] + " " + @approver[:last_name] + " just approved your shift swap with #{@coverer[:first_name]} #{@coverer[:last_name]} 🙋"
            @message = I18n.t('push.shift.approve') % {:approver_name => @approver[:first_name] + " " + @approver[:last_name], :user_name => @coverer[:first_name] + " " + @coverer[:last_name]}
            #UserAnalytic.create(:action => 7, :org_id => @post[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
            mession = Mession.where(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:owner_id]]).first
            mession.target_push('open_app', @message, nil, nil, 'silent.mp3', nil)
          end

          if Mession.exists?(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:coverer_id]])
            @approver = User.find(params[:user_id])
            #@message = "Hey! " + @approver[:first_name] + " " + @approver[:last_name] + " just approved your shift swap with #{@poster[:first_name]} #{@poster[:last_name]} 🙋"
            @message = I18n.t('push.shift.approve') % {:approver_name => @approver[:first_name] + " " + @approver[:last_name], :user_name => @poster[:first_name] + " " + @poster[:last_name]}
            #UserAnalytic.create(:action => 7, :org_id => @post[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
            mession = Mession.where(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:coverer_id]]).first
            mession.target_push('open_app', @message, nil, nil, 'silent.mp3', nil)
          end
          @schedule_element.check_user(params[:user_id])
          render json: @schedule_element, serializer: ShiftStandaloneSerializerSelfRoot
        elsif result == "covered"
          render json: { "code" => -1, "message" => "This shift is already covered and/or approved.", "error" => "The status code of the shift is covered."}
        else
          ErrorLog.create(
            :file => "schedule_elements_controller.rb",
            :function => "approve",
            :error => "fell into the else portion of the loop")
          render json: { "code" => -1, "message" => "Ops...Something went wrong!.", "error" => "Shouldn't land here but it did."}
        end

      end

      def reject
        @post = Post.find(params[:post_id])
        @post.touch
        @req = Channel.find(@post[:channel_id])

        result = @schedule_element.reject(params[:user_id], @req[:shift_trade_require_approval])
        if result == "inapplicable"
          render json: { "code" => -1, "message" => "This location does not require shift trade approval.", "error" => "This location does not require shift trade approval."}
        elsif result == "deleted"
          render json: { "code" => -1, "message" => "This shift is already deleted by the poster.", "error" => "The status code of the shift is deleted."}
        elsif result == "uncovered"
          render json: { "code" => -1, "message" => "This shift has not yet been covered.", "error" => "The status code of the shift is not covered."}
        elsif result == "success"
          @poster = User.find(@schedule_element[:owner_id])
          @coverer = User.find(@schedule_element[:coverer_id])
          @approver = User.find(params[:user_id])
          if Mession.exists?(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:owner_id]])
            #@message = "🙍 " + @approver[:first_name] + " " + @approver[:last_name] + " just rejected your shift swap with #{@coverer[:first_name]} #{@coverer[:last_name]}. Try reposting?"
            @message = I18n.t('push.shift.reject') % {:approver_name => @approver[:first_name] + " " + @approver[:last_name], :user_name => @coverer[:first_name] + " " + @coverer[:last_name]}
            #UserAnalytic.create(:action => 7, :org_id => @post[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
            mession = Mession.where(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:owner_id]]).first
            mession.target_push('open_app', @message, nil, nil, 'silent.mp3', nil)
          end

          if Mession.exists?(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:coverer_id]])
            @approver = User.find(params[:user_id])
            #@message = "🙍 " + @approver[:first_name] + " " + @approver[:last_name] + " just rejected your shift swap with #{@poster[:first_name]} #{@poster[:last_name]}. Good try!💁"
            @message = I18n.t('push.shift.reject') % {:approver_name => @approver[:first_name] + " " + @approver[:last_name], :user_name => @poster[:first_name] + " " + @poster[:last_name]}
            #UserAnalytic.create(:action => 7, :org_id => @post[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
            mession = Mession.where(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:coverer_id]]).first
            mession.target_push('open_app', @message, nil, nil, 'silent.mp3', nil)
          end
          @schedule_element.check_user(params[:user_id])
          render json: @schedule_element, serializer: ShiftStandaloneSerializerSelfRoot
        elsif result == "covered"
          render json: { "code" => -1, "message" => "This shift is already covered and/or approved.", "error" => "The status code of the shift is covered."}
        else
          ErrorLog.create(
            :file => "schedule_elements_controller.rb",
            :function => "approve",
            :error => "fell into the else portion of the loop")
          render json: { "code" => -1, "message" => "Ops...Something went wrong!.", "error" => "Shouldn't land here but it did."}
        end

      end

      def uncover
        #UserAnalytic.create(:action => 8, :org_id => @schedule_element[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
        Post.find(params[:post_id]).touch
        if @schedule_element.uncover
          render json: @schedule_element, serializer: ShiftStandaloneSerializerSelfRoot
        else
          render json: { "code" => -187, "message" => @schedule_element.errors }
        end
      end

      def invite_to_cover_via_sms
        t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
        t_token = '81eaed486465b41042fd32b61e5a1b14'

        @client = Twilio::REST::Client.new t_sid, t_token


        if Rails.env.production?
          @host = "http://goo.gl/isddrw"
        elsif Rails.env.staging?
          @host = "http://goo.gl/isddrw"
        elsif Rails.env.testing?
          @host = "http://goo.gl/isddrw"
        else
          @host = "http://goo.gl/isddrw"
        end

        if @user[:location] != 1
          @organization = Organization.where(:id => @user[:active_org]).first
          network_name = @organization[:name]
        else
          @organization = Location.where(:id => @user[:location]).first
          network_name = @location[:location_name]
        end

        #phone_number = params[:phone].gsub(/[\+\-\(\)\s]/,'')
        phone_number = params[:phone].gsub(/\W/,'')
        message = @client.account.messages.create(
          #:body => "#{@user.first_name} #{@user.last_name} has invited you to download the app they’re using to trade shifts and message coworkers. It’s called Coffee Mobile, download here: #{@host}",
          :body => "#{@user.first_name} #{@user.last_name} requested you to cover a shift at #{network_name} on their workplace mobile app Coffee Mobile, download it help them out here. #{@host}",
          #:to => params[:phone],
          :to => phone_number.size > 10 ? "+"+ phone_number : phone_number,
          :from => "+16137028842"
        )

        if message
          render json: { "eXpresso" => { "code" => 1, "message" => "Invitation sent" } }
        else
          render json: { "eXpresso" => { "code" => -111, "message" => message.errors } }
        end
      end

      def delete_shift
        begin
          #Post.update(params[:post_id], :is_valid => false)
          Post.update(params[:post_id], :is_valid => false, :z_index => 9999)
          @schedule_element.update_attribute(:is_valid, false)
          render json: { "code" => 1, "message" => "Success" }
        rescue
          render json: { "code" => -1, "message" => "Something went wrong." }
        ensure
          #UserAnalytic.create(:action => 9, :org_id => @schedule_element[:org_id], :user_id => @schedule_element[:user_id], :source_id => @schedule_element[:id], :ip_address => request.remote_ip.to_s)
        end
      end
    end
  end
end
