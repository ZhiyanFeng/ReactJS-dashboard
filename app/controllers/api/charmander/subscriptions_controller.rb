include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
    class SubscriptionsController < ApplicationController
      class Subscription < ::Subscription
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :set_headers
      before_filter :fetch_subscription, :except => [:setup_existing_subscriptions]

      respond_to :json

      def fetch_subscription
        if Subscription.exists?(:id => params[:id])
          @subscription = Subscription.find_by_id(params[:id])
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Cannot find subscription with id #{params[:id]}." } }
        end
      end

      def refresh_subscription
        if @subscription[:subscription_last_synchronize].present?
          @posts = Post.where("(z_index < 9999 OR owner_id = #{params[:user_id]}) AND post_type in (5,6,7,8,9,1,2,3,4,10) AND channel_id = #{@subscription[:channel_id]} AND updated_at > '#{@subscription[:subscription_last_synchronize]}'").order('created_at DESC')
        else
          @posts = Post.where("(z_index < 9999 OR owner_id = #{params[:user_id]}) AND post_type in (5,6,7,8,9,1,2,3,4,10) AND channel_id = #{@subscription[:channel_id]}").order('created_at DESC').limit(15)
        end
        @subscription.update_attribute(:subscription_last_synchronize, Time.now)
        render json: @posts, each_serializer: SyncFeedSerializer
      end

      def quit
        if Subscription.exists?(:id => params[:id])
          @subscription = Subscription.find(params[:id])
          if @subscription[:user_id] == params[:user_id].to_i
            @user = User.find(params[:user_id])
            @channel = Channel.find(@subscription[:channel_id])
            if @channel[:channel_type] == "location_feed"
              @access_key = UserPrivilege.where(:owner_id => @user[:id], :location_id => @channel[:channel_frequency].to_i).first
            else
              @access_key = true
            end
            if @user && @access_key && @channel
              if @channel[:channel_type] == "location_feed"
                @access_key.update_attributes(:is_approved => false, :is_valid => false)
                @user.update_attribute(:access_key_count, @user[:access_key_count] - 1)
              end
              @subscription.update_attributes(:is_active => false, :is_valid => false, :subscription_last_synchronize => nil)
              @channel.recount
              render json: { "eXpresso" => { "code" => 1 } }
            else
              render json: { "eXpresso" => { "code" => -1, "error" => "There was an error unsubscribing you from the channel, it has been reported to the Coffee Team and will be resolved shortly." } }
            end
          else
            render json: { "eXpresso" => { "code" => -1, "error" => "Subscription with id #{params[:id]} does not belong to this user." } }
          end
        end
      end

      def set_subscription_stick_to_top
        if @subscription.update_attribute(:subscription_stick_to_top, params[:stick_to_top])
          render json: { "eXpresso" => { "code" => 1 } }
        else
          render json: { "eXpresso" => { "code" => -1 } }
        end
      end

      def set_subscription_nickname
        if @subscription.update_attribute(:subscription_nickname, params[:nickname])
          render json: { "eXpresso" => { "code" => 1 } }
        else
          render json: { "eXpresso" => { "code" => -1 } }
        end
      end

      def set_subscription_mute_notifications
        if @subscription.update_attribute(:subscription_mute_notifications, params[:mute])
          render json: { "eXpresso" => { "code" => 1 } }
        else
          render json: { "eXpresso" => { "code" => -1 } }
        end
      end

      def load_more
        result = {}
        result["server_sync_time"] = DateTime.now.iso8601(3)
        result["posts"] ||= Array.new
        if @subscription[:is_coffee]
          @posts = Post.where("post_type in (5,6,7,8,9,1,2,3,4,10,21) AND channel_id = #{@subscription[:channel_id]} AND id < #{params[:post_id]} AND is_valid").order('created_at DESC').limit(15)
        else
          @posts = Post.where("post_type in (5,6,7,8,9,1,2,3,4,10,21) AND channel_id = #{@subscription[:channel_id]} AND id < #{params[:post_id]} AND (z_index < 9999 OR owner_id = #{@subscription[:user_id]}) AND is_valid").order('created_at DESC').limit(15)
        end
        @posts.each do |p|
          p.check_user(params[:user_id])
        end
        @posts.map do |post|
          result["posts"].push(SyncFeedSerializer.new(post, root: false))
        end
        render json: { "eXpresso" => result }
      end

      def setup_existing_subscriptions
        count_subscriptions = 0
        count_channels = 0
        if coffee_channel = Channel.create(
            :channel_type => "coffee_feed",
            :channel_frequency => "1",
            :channel_name => "Coffee Mobile",
            :owner_id => 134,
            :allow_post => true,
            :allow_comment => true,
            :allow_like => true,
            :allow_shift_trade => false,
            :allow_schedule => false,
            :allow_announcement => false
          )
          count_channels = count_channels + 1
          User.all.each do |user|
            if coffee_subscription = Subscription.create(
                :user_id => user[:id],
                :channel_id => coffee_channel[:id]
              )
              count_subscriptions = count_subscriptions + 1
            end
          end
          coffee_channel.recount
        end

        Organization.where("id != 1").each do |organization|
          if organization_channel = Channel.create(
              :channel_type => "organization_feed",
              :channel_frequency => organization[:id].to_s,
              :channel_name => organization[:name],
              :owner_id => 134,
              :allow_post => true,
              :allow_comment => true,
              :allow_like => true,
              :allow_shift_trade => false,
              :allow_schedule => false,
              :allow_announcement => true
            )
            count_channels = count_channels + 1
            User.where(:active_org => organization[:id]).each do |user|
              if organiztion_subscription = Subscription.create(
                  :user_id => user[:id],
                  :channel_id => organization_channel[:id]
                )
                count_subscriptions = count_subscriptions + 1
              end
            end
            organization_channel.recount
          end
        end

        Location.all.each do |location|
          if location_channel = Channel.create(
              :channel_type => "location_feed",
              :channel_frequency => location[:id].to_s,
              :channel_name => location[:location_name],
              :owner_id => 134,
              :allow_post => true,
              :allow_comment => true,
              :allow_like => true,
              :allow_shift_trade => true,
              :allow_schedule => true,
              :allow_announcement => true
            )
            count_channels = count_channels + 1
            User.where(:location => location[:id]).each do |user|
              if location_subscription = Subscription.create(
                  :user_id => user[:id],
                  :channel_id => location_channel[:id]
                )
                count_subscriptions = count_subscriptions + 1
              end
            end
            location_channel.recount
          end
        end

        render json: { "eXpresso" => { "code" => 1, "channels" => "#{count_channels} channels created", "subscriptions" => "#{count_subscriptions} subscriptions created" } }
      end

      def delete

      end

      def archive
        if Subscription.exists?(:id => params[:id])
          @subscription = Subscription.find(params[:id])
          if @subscription[:is_valid]
            if @subscription[:is_active]
              if @subscription.update_attributes(:is_active => false)
                render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
              else
                render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant failed to update.", "error" => "Subscription with ID #{@subscription[:id]} failed to update." } }
              end
            else
              render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant is not active.", "error" => "Subscription with ID #{@subscription[:id]} is already inactive." } }
            end
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant is deleted.", "error" => "Subscription with ID #{@subscription[:id]} is already deleted." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant does not exist.", "error" => "Subscription with ID #{params[:id]}." } }
        end
      end

    end
  end
end
