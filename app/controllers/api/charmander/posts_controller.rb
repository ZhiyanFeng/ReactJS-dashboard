include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
    class PostsController < ApplicationController
      class Post < ::Post
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :except => [:compose_web, :reorder]
      before_filter :validate_session, :except => [:compose_dashboard]
      before_filter :set_headers

      respond_to :json

      def update
        @post = Post.find(params[:id])
        if @post.update!(params[:post])
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -922, "message" => @post.errors } }
        end
      end

      def compose
        @user = User.find(params[:owner_id])
        if @user[:is_valid]
          @channel = Channel.find(params[:channel_id])
          @sub = Subscription.where(:user_id => @user[:id], :channel_id => @channel[:id], :is_valid => true).first
          if @channel[:allow_post] || (@sub.present? && @sub[:allow_post] > 0)
            if @channel[:channel_type] == "location_feed"
              location_id = @channel[:channel_frequency].to_i
            elsif @channel[:channel_type] == "coffee_feed"
              location_id = 1153
            else
              location_id = @user[:location]
            end
            if Subscription.exists?(:user_id => @user[:id], :channel_id => @channel[:id], :is_valid => true) || @user[:id] == 134
              @post = Post.new(
                :org_id => 1,
                :owner_id => params[:owner_id],
                :title => params[:title],
                :content => params[:content],
                :location => location_id,
                :channel_id => @channel[:id],
                :post_type => PostType.reference_by_description(params[:reference])
              )
              image = params[:file].presence ? params[:file] : nil
              video = params[:video].presence ? params[:video] : nil
              event = params[:event].presence ? params[:event] : nil
              poll = params[:poll].presence ? params[:poll] : nil
              if @post.save
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

                if @user[:system_user] == true
                  if @channel[:id] == 1
                    @post.update_attributes(:allow_comment => false, :allow_like => false, :z_index => 0)
                  end
                end
                #push_notification = params[:push_notification] == "true" ? true : false
                push_notification = true
                @post.update_attribute(:is_valid, false) if image != nil
                post_base_type = PostType.find_post_type(@post[:post_type])
                UserAnalytic.create(:action => 1,:org_id => 1, :user_id => params[:owner_id], :ip_address => request.remote_ip.to_s)
                if post_base_type == "announcement"
                  render json: @post, serializer: SyncFeedSerializer
                else
                  render json: @post, serializer: SyncFeedSerializer
                end
                @post.compose_v_four(image, video, event, poll, nil, nil, nil, push_notification)

                if ((!params[:make_private].present? || params[:make_private] == "false") || @user[:system_user] == true) && push_notification == true
                  #@channel.subscribers_push(post_base_type, @post)
                  @channel.tracked_subscriber_push(post_base_type,@post)
                end
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
                    @post.process_attachments(params[:attachments], @user[:id], params[:tip_amount])
                  else
                    @post.process_attachments(params[:attachments], @user[:id])
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

      def destroy
        if Post.exists?(:id => params[:id])
          @post = Post.find(params[:id])
          if @post.update(:is_valid => false) && @post[:channel_id] != 1
            @channel = Channel.find(@post[:channel_id])
            #CHANGE TO NONE SCHEDULE POSTS
            @last_post = Post.where(:channel_id => @channel[:id], :is_valid => true).order("created_at DESC").first
            if @last_post.present?
              @user = User.find(@last_post[:owner_id])
              @channel.update_attribute(:channel_latest_content, "#{@user[:first_name]} #{@user[:last_name]}: #{@last_post[:content]}")
              #Subscription.where(:channel_id => @channel[:id], :is_valid => true).each do |s|
              #  s.touch
              #end
              Subscription.where(:channel_id => @channel[:id], :is_valid => true).update_all(:updated_at => Time.now)
            else
              @channel.update_attribute(:channel_latest_content, "")
              Subscription.where(:channel_id => @channel[:id], :is_valid => true).update_all(:updated_at => Time.now)
              #Subscription.where(:channel_id => @channel[:id], :is_valid => true).each do |s|
              #  s.touch
              #end
            end
            render :json => { "eXpresso" => { "code" => 1, "post" => @post } }
          else
            render :json => { "eXpresso" => { "code" => 0, "error" => @post.errors } }
          end
        end
      end

      def detail
        post = Post.where(:id => params[:id]).includes(:likes, :flags, :comments => [:likes, :flags]).first
        UserAnalytic.create(:action => 2,:org_id => post[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
        if !params[:silent].present?
          Notification.did_view(params[:user_id], 4, params[:id]) unless params[:reset_count].present?
          post.add_view
        end

        post.check_user(params[:user_id])

        post.comments.each do |p|
          p.check_user(params[:user_id])
        end
        if PostType.find_post_type(post[:post_type]) == "post"
          render json: post, serializer: FeedDetailSerializer
        elsif PostType.find_post_type(post[:post_type]) == "announcement"
          render json: post, serializer: FeedDetailSerializer
        else
          render json: post, serializer: FeedDetailSerializer
        end
      end

      def comment
        post = Post.find(params[:id])
        #push = params[:dont_push].present? ? false : true
        if params[:dont_push].present?
          push = false
        #elsif !Subscription.exists?(:user_id => post[:owner_id], :is_valid => true, :subscription_mute_notifications => true)
        #  push = false
        else
          push = true
        end
        @comment = Comment.new(
          :content => params[:content],
          :owner_id => params[:user_id],
          :source => 4,
          :source_id => post[:id]
        )
        if @comment.create_comment("post", post, push)
          render json: @comment, serializer: CommentCreateSerializer
        else
          render json: @comment.errors
        end
      end

      def like
        post = Post.find(params[:id])
        if params[:dont_push].present?
          push = false
        #elsif !Subscription.exists?(:user_id => post[:owner_id], :is_valid => true, :subscription_mute_notifications => true)
        #  push = false
        else
          push = true
        end
        #push = params[:dont_push].present? ? false : true
        @like = Like.new(
          :owner_id => params[:user_id],
          :source => Source.id_from_name(PostType.find_post_type(post[:post_type])),
          :source_id => params[:id]
        )
        @like.create_like("post", post, push)
        #Mession.broadcast(post[:org_id], "refresh", "notification", 4, post[:id], params[:user_id], post[:owner_id])
        render json: @like, serializer: LikeSerializer
      end

      def tip
        post = Post.find(params[:id])
        if params[:user_id].to_i == post[:owner_id].to_i || params[:user_id].to_i == 134
          if params[:dont_push].present?
            push = false
          else
            push = true
          end
          @gratitude = Gratitude.new(
            :amount => params[:tip_amount],
            :shift_id => params[:shift_id],
            :owner_id => params[:user_id],
            :source => 4,
            :source_id => post[:id]
          )
          if @gratitude.create_gratitude(post, push)
            #render json: { "code" => 1, "message" => "Success" }
            @schedule_element = ScheduleElement.find(params[:shift_id])
            render json: @schedule_element, serializer: ShiftSerializer
          else
            render json: { "code" => -1, "message" => "Could not tip this shift at the moment" }
          end
        else
          render json: { "code" => -1, "message" => "You cannot add a tip to a shift you did not post at the moment. Sorry!" }
        end
      end

      def unlike
        post = Post.find(params[:id])
        if Like.exists?(:owner_id => params[:user_id], :source => 4, :source_id => params[:id], :is_valid => true)
          @like = Like.where(:owner_id => params[:user_id], :source => 4, :source_id => params[:id], :is_valid => true).last
          @like.destroy_like

          render json: @like, serializer: LikeSerializer
        else
          render json: "-1001: Operation could not be completed. Object does not exist.", status: 422
        end
      end

      def flag
        post = Post.find(params[:id])
        @flag = Flag.new(
          :owner_id => params[:user_id],
          :source => Source.id_from_name(PostType.find_post_type(post[:post_type])),
          :source_id => params[:id]
        )
        @flag.create_flag(params[:id])

        render json: @flag, serializer: FlagSerializer
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
