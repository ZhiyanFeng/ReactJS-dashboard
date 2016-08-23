include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Ditto
    class PostsController < ApplicationController
      class Post < ::Post
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :except => []
      before_filter :validate_session, :except => []
      before_filter :set_headers

      respond_to :json


      def create
        @user = User.find(params[:owner_id])
        if @user[:is_valid]
          @channel = Channel.find(params[:channel_id])
          if @channel[:allow_post]
            if @channel[:channel_type] == "location_feed"
              location_id = @channel[:channel_frequency].to_i
            elsif @channel[:channel_type] == "coffee_feed"
              location_id = 1153
            else
              location_id = @user[:location]
            end
            if Subscription.exists?(:user_id => @user[:id], :channel_id => @channel[:id], :is_valid => true) || @user[:id] == 134
              if params[:reference].present?
                pt = PostType.get_base_type(params[:reference])
              elsif params[:post_type].present?
                pt = PostType.reference_by_description(params[:post_type])
              end
              @post = Post.new(
                :org_id => 1,
                :owner_id => params[:owner_id],
                :title => params[:title],
                :content => params[:content],
                :channel_id => @channel[:id],
                :location => location_id,
                #:post_type => PostType.get_base_type(params[:reference])
                :post_type => pt
              )
              # Set archtype
              if params[:title] == "Shift Trade"
                @post.set_archtype("shift_trade")
              end
              # Set visibility
              if params[:make_private].present? && params[:make_private] == "true"
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

              if params[:attachment_id].present?
                @post.update_attribute(:attachment_id, params[:attachment_id])
              end

              if @post.save
                Follower.follow(4, @post[:id], @post[:owner_id])
                post_base_type = PostType.find_post_type(@post[:post_type])
                UserAnalytic.create(:action => 1,:org_id => params[:org_id], :user_id => params[:owner_id], :ip_address => request.remote_ip.to_s)
                render json: @post, serializer: SyncFeedSerializer
                if params[:attachments].present?
                  if params[:tip_amount].present?
                    @post.process_attachments(params[:attachments], @user[:id], params[:tip_amount], @channel[:id], @post[:id])
                  else
                    @post.process_attachments(params[:attachments], @user[:id], @channel[:id], @post[:id])
                  end
                end
                @user.process_tags(params[:tags]) if params[:tags].present?

                #@channel.subscribers_push(post_base_type, @post)
                @channel.tracked_subscriber_push(post_base_type,@post)
              else
                render :json => { "eXpresso" => { "code" => -1, "error" => "Cannot process posts" } }
              end
            else
              render :json => { "eXpresso" => { "code" => -1, "error" => "Subscription is invalid" } }
            end
          else
            render :json => { "eXpresso" => { "code" => -1, "error" => "Cannot post to this channel" } }
          end
        else
          render :json => { "eXpresso" => { "code" => -1, "error" => "Not a valid user account" } }
        end
      end

      private

      def restrict_access
        #X-Method: cc5f43ea7132996963e9a62fabde3c6f
        #Authorization: Token token="cc5f43ea7132996963e9a62fabde3c6f", nonce="def"
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end
    end
  end
end