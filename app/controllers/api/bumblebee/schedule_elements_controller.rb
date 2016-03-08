include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class ScheduleElementsController < ApplicationController
      class ScheduleElement < ::ScheduleElement
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end

      before_filter :restrict_access, :set_headers, :fetch_schedule_element
      
      respond_to :json
      
      def fetch_schedule_element
        if ScheduleElement.exists?(:id => params[:id])
          @schedule_element = ScheduleElement.find_by_id(params[:id])
        end
      end

      def cover
        @post = Post.find(params[:post_id])
        @post.touch
        result = @schedule_element.cover(params[:user_id])
        if result == "success"
          if Mession.exists?(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:owner_id]])
            @coverer = User.find(params[:user_id])
            @message = @coverer[:first_name] + " " + @coverer[:last_name] + " has agreed to cover your shift."
            #UserAnalytic.create(:action => 7, :org_id => @post[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
            mession = Mession.where(['user_id = ? AND is_active AND push_id IS NOT NULL', @schedule_element[:owner_id]]).first
            mession.target_push('open_app', @message, nil, nil, 'silent.mp3', nil)
          end
          render json: @schedule_element, serializer: ShiftSerializer
        elsif result == "covered"
          render json: { "code" => -186, "message" => "Shift already covered by someone else." }
        elsif result == "deleted"
          render json: { "code" => -188, "message" => "Shift deleted by owner." }
        else
          render json: { "code" => -1, "message" => @schedule_element.errors }
        end
      end

      def uncover
        #UserAnalytic.create(:action => 8, :org_id => @schedule_element[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
        Post.find(params[:post_id]).touch
        if @schedule_element.uncover
          render json: @schedule_element, serializer: ShiftSerializer
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

        message = @client.account.messages.create(
          #:body => "#{@user.first_name} #{@user.last_name} has invited you to download the app they’re using to trade shifts and message coworkers. It’s called Coffee Mobile, download here: #{@host}",
          :body => "#{@user.first_name} #{@user.last_name} requested you to cover a shift at #{network_name} on their workplace mobile app Coffee Mobile, download it help them out here. #{@host}",
          :to => params[:phone],
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
          Post.update(params[:post_id], :is_valid => false)
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