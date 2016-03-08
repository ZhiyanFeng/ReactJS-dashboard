include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
    class SchedulesController < ApplicationController
      class Schedule < ::Schedule
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end

      before_filter :set_headers
      
      respond_to :json
      
      def make_schedule
        if web_access
          @post = Post.new(
            :org_id => params[:org_id],
            :owner_id => params[:user_id],
            :title => params[:name],
            :content => "The team manager has posted a new schedule, click below to import it to your calendar.", 
            :post_type => PostType.reference_by_description(params[:reference])
          )
          image = params[:file].presence ? params[:file] : nil
          video = params[:video].presence ? params[:video] : nil
          event = params[:event].presence ? params[:event] : nil
          poll = params[:poll].presence ? params[:poll] : nil
          schedule = params[:schedule].presence ? params[:schedule] : nil
          if @post.save
            @post.compose(image, video, event, poll, schedule)
          end
          redirect_to schedules_path
        else
          redirect_to schedules_path
        end
      end

      def make_schedule_snapshot
        @user = User.find(params[:user_id])
        week_number = DateTime.strptime(params[:start_date], '%U')
        year = DateTime.strptime(params[:start_date], '%Y')
        start_human = params[:start_date].to_date
        end_human = params[:end_date].to_date
        @schedule_snapshot = Schedule.new(
          :name => params[:title],
          :org_id => 1,
          :location_id => params[:location],
          :start_date => params[:start_date],
          :end_date => params[:end_date],
          :snapshot_url => params[:url],
          :is_valid => false
        )

        if @schedule_snapshot.save
          @post = Post.new(
            :org_id => 1,
            :location => params[:location],
            :channel_id => params[:channel_id],
            :owner_id => @user[:id],
            :title => params[:title],
            :content => "#{@user.first_name} #{@user.last_name} posted schedule for #{start_human} ~ #{end_human}",
            :post_type => PostType.reference_by_description("schedule_with_snapshot"),
            :is_valid => false
          )
          # Set archtype
          @post.set_archtype("schedule_snapshot")
          # Set visibility
          if params[:make_private].present? && params[:make_private].to_s == "true"
            @post.update_attribute(:z_index, 9999)
          end

          # Set allow comments
          if params[:allow_comment].present? && params[:allow_comment] == "false"
            @post.update_attribute(:allow_comment, false)
          end

          # Set allow likes
          if params[:allow_like].present? && params[:allow_like] == "false"
            @post.update_attribute(:allow_like, false)
          end
          if @post.save
            if @post.attach_schedule_snapshot(@schedule_snapshot)
              @post.update_attribute(:is_valid, true)
              @schedule_snapshot.update_attribute(:is_valid, true)
              if params[:make_private].present? && params[:make_private].to_s == "true"
              else
                #message = "#{@user.first_name} #{@user.last_name} posted schedule for #{start_human} ~ #{end_human}"
                if @channel = Channel.find(params[:channel_id])
                  @channel.subscribers_push("schedule", @post)
                end
                #User.location_broadcast(@user[:id], @user[:location], "post", "schedule", message, 4, @post[:id], created_at = nil, user_group=nil) if @user[:location] != 0
                #def self.location_broadcast(sender_id, location, type, event, message, source, source_id, created_at = nil, user_group=nil)
              end
              render json: { "eXpresso" => { "code" => 1, "body" => SyncNewsfeedSerializer.new(@post, root: false), "message" => "success" } }
            else
              render json: { "eXpresso" => { "code" => -1, "message" => @post.errors } }
            end
          else
            render json: { "eXpresso" => { "code" => -1, "message" => @post.errors } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => @schedule_snapshot.errors } }
        end
      end
    end
  end
end