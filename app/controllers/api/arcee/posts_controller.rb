include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class PostsController < ApplicationController
      class Post < ::Post
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :except => [:compose_web, :reorder]
      #before_filter :validate_session, :except => [:compose_dashboard]
      before_filter :set_headers
      
      respond_to :json

      def index
        @posts = Post.all
        render json: @posts, each_serializer: PostSerializer
      end

      def show
        @post = Post.find(params[:id])
        render json: @post, serializer: PostSerializer
      end

      def update
        @post = Post.find(params[:id])
        if @post.update!(params[:post])
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -922, "message" => @post.errors } }
        end
      end

      def dashboard_update
        if Post.dashboard_update(params[:data])
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -922, "message" => "Failed" } }
        end
      end

      def update_training
        error = false
        if params[:id].present?
          @post = Post.find(params[:id]) 
          #if !@post.update!(params[:post])
          #  error = true
          #end
          begin
            Post.transaction do
              @post.update_attribute(:title, params[:post][:title]) if params[:post][:title].presence
              @post.update_attribute(:content, params[:post][:content]) if params[:post][:content].presence
              @post.update_attribute(:created_at, params[:created_at]) if params[:created_at].presence
              #@post.update_attribute(:push_notification, params[:push_notification]) if params[:status].presence
              @post.update_attribute(:attachment_id, params[:attachment_id]) if params[:attachment_id].presence
              if params[:video].present?
                if @post.replace_video(params[:video])

                else
                  error = true
                end
              end
            end
          rescue
            error = true
          end

        end

        if error == false
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -923, "message" => "Something went wrong" } }
        end
      end

      def create
        @user = User.find(params[:owner_id])
        if @user[:active_org] == 1
          @post = Post.new(
            :org_id => params[:org_id],
            :owner_id => params[:owner_id],
            :location => @user[:location],
            :title => params[:title],
            :content => params[:content], 
            :post_type => PostType.get_base_type(params[:reference])
          )
        else
          @post = Post.new(
            :org_id => params[:org_id],
            :owner_id => params[:owner_id],
            :title => params[:title],
            :content => params[:content], 
            :post_type => PostType.get_base_type(params[:reference])
          )
        end

        if @post.save
          #UserAnalytic.create(:action => 1,:org_id => params[:org_id], :user_id => params[:owner_id], :ip_address => request.remote_ip.to_s)
          render json: @post, serializer: SyncNewsfeedSerializer
          @post.process_attachments(params[:attachments])
        else
          render json: @post.errors
        end
      end

      #def update
      #  if Post.exists?(:id => params[:id])
      #    @post = Post.find(params[:id])
      #    if @post.update(params[:post])
      #      render :json => @post, serializer: PostSerializer
      #    else
      #      render :json => @post.errors
      #    end
      #  end
      #end

      #def destroy
      #  if Post.exists?(:id => params[:id])
      #    @post = Post.find(params[:id])
      #    if @post.update(:is_valid => false)
      #      render :json => @post, serializer: PostSerializer
      #    else
      #      render :json => @post.errors
      #    end
      #  end
      #end
      
      def compose
        @user = User.find(params[:owner_id])
        if @user[:active_org] == 1
          if Channel.exists?(:channel_type => 'location_feed', :channel_frequency => @user[:location].to_s)
            @channel = Channel.where(:channel_type => 'location_feed', :channel_frequency => @user[:location].to_s).first
            if Subscription.exists?(:user_id => @user[:id], :channel_id => @channel[:id], :is_valid => true, :is_active => true)
              channel_id = @channel[:id]
            else
              channel_id = @channel[:id]
            end
          else
            channel_id = nil
          end
          @post = Post.new(
            :org_id => params[:org_id],
            :owner_id => params[:owner_id],
            :location => @user[:location],
            :title => params[:title],
            :content => params[:content], 
            :channel_id => channel_id,
            :post_type => PostType.reference_by_description(params[:reference])
          )
        else
          if Channel.exists?(:channel_type => 'organization_feed', :channel_frequency => @user[:active_org].to_s)
            @channel = Channel.where(:channel_type => 'organization_feed', :channel_frequency => @user[:active_org].to_s).first
            if Subscription.exists?(:user_id => @user[:id], :channel_id => @channel[:id], :is_valid => true, :is_active => true)
              channel_id = @channel[:id]
            else
              channel_id = @channel[:id]
            end
          else
            channel_id = nil
          end
          @post = Post.new(
            :org_id => params[:org_id],
            :owner_id => params[:owner_id],
            :title => params[:title],
            :content => params[:content], 
            :channel_id => channel_id,
            :post_type => PostType.reference_by_description(params[:reference])
          )
        end
        image = params[:file].presence ? params[:file] : nil
        video = params[:video].presence ? params[:video] : nil
        event = params[:event].presence ? params[:event] : nil
        poll = params[:poll].presence ? params[:poll] : nil
        if @post.save
          push_notification = params[:push_notification] == "true" ? true : false
          @post.update_attribute(:is_valid, false) if image != nil
          if PostType.find_post_type(@post[:post_type]) == "announcement"
            render json: @post, serializer: AnnouncementSerializer            
          else
            render json: @post, serializer: PostSerializer
          end
          @post.compose(image, video, event, poll, nil, nil, nil, push_notification)
        else
          render json: @post.errors
        end
      end
      
      def compose_announcement
        @post = Post.new(params[:post])
        image = params[:file].presence ? params[:file] : nil
        video = params[:video].presence ? params[:video] : nil
        #params[:video].presence ? Rails.logger.debug("Found") : Rails.logger.debug("NOT Found")
        event = params[:event].presence ? params[:event] : nil
        if @post.save
          @post.update_attribute(:created_at, params[:created_at]) if params[:created_at].present?
          @post.update_attribute(:is_valid, false) if image != nil
          render json: @post, serializer: PostSerializer
          @post.compose(image, video, event)
        else
          render json: @post.errors
        end
      end

      def compose_dashboard
        Post.transaction do
          @post = Post.new(params[:post])
          image = params[:file].presence ? params[:file] : nil
          video = params[:video].presence ? params[:video] : nil
          schedule = params[:schedule].presence ? params[:schedule] : nil
          #params[:video].presence ? Rails.logger.debug("Found") : Rails.logger.debug("NOT Found")
          event = params[:event].presence ? params[:event] : nil
          poll = params[:poll].presence ? params[:poll] : nil
          safety_course = nil;

          if @post.save
            #@post.update_attribute(:created_at, params[:created_at]) if params[:created_at].present?

            @post.update_attribute(:attachment_id, params[:attachment_id]) if params[:attachment_id].present?

            @post.update_attribute(:is_valid, false) if image != nil
            push_notification = params[:push_notification] == "true" ? true : false

            if params[:attachment_id].present?
              @post.compose_with_attachment_id(params[:attachment_id], params[:created_at], push_notification)
            else
              @post.compose(image, video, event, poll, schedule, safety_course, params[:created_at], push_notification)
            end
            render json: @post, serializer: PostSerializer
          else
            render json: @post.errors
          end
        end
      end


      
      def compose_web
        @post = Post.new(params[:post])
        image = params[:file].presence ? params[:file] : nil
        video = params[:video].presence ? params[:video] : nil
        #params[:video].presence ? Rails.logger.debug("Found") : Rails.logger.debug("NOT Found")
        event = params[:event].presence ? params[:event] : nil
        if params[:post][:attachment_id].present?
          if @post.save
            render json: @post, serializer: PostSerializer
          end
        else
          if @post.save
            @post.update_attribute(:created_at, params[:created_at]) if params[:created_at].present?
            @post.update_attribute(:is_valid, false) if image != nil
            render json: @post, serializer: PostSerializer

            @post.compose(image, video, event)
          else
            render json: @post.errors
          end
        end
      end
          
      def create_post
        @post = Post.new(
          :org_id => params[:org_id],
          :owner_id => params[:owner_id],
          :title => params[:title],
          :content => params[:content], 
          :post_type => PostType.reference_by_description(params[:reference])
        )
        
        if is_equal_to(params[:reference], "post_with_image") ||
          is_equal_to(params[:reference], "training_with_image")          
          @post.post_with_image(params[:file])
        elsif is_equal_to(params[:reference], "announcement_with_image")
          @post.announcement_with_image(params[:file])
        elsif is_equal_to(params[:reference], "announcement_with_video") || 
          is_equal_to(params[:reference], "post_with_video") || 
          is_equal_to(params[:reference], "training_with_video")
          @post.post_with_video(params[:video])
        elsif is_equal_to(params[:reference], "announcement_with_event") || 
          is_equal_to(params[:reference], "post_with_event")
          @post.post_with_event(params[:event])
        else
          Rails.logger.debug("others")
          @post.save
        end
        UserNotificationCounter.increment(params[:org_id], PostType.find_post_type(@post[:post_type]), params[:owner_id])
        Follower.follow(4, @post[:id], params[:owner_id])
        respond_to do |format|  
          format.html { render json: @post, serializer: PostSerializer }
          format.json { render json: @post, serializer: PostSerializer }
        end
      end
      
      def destroy
        if Post.exists?(:id => params[:id])
          @post = Post.find(params[:id])
          if @post.update!(:is_valid => false)
            render :json => { "eXpresso" => { "code" => 1, "post" => @post } }
          else
            render :json => { "eXpresso" => { "code" => 0, "error" => @post.errors } }
          end
        end
      end
      
      def comment
        post = Post.find(params[:id])
        push = params[:dont_push].present? ? false : true
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
      
      def reorder
        ids = params[:order].split(',')
        ids.each do |p|
          @post = Post.find(p)
          @post.touch
        end
        render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        #params[:trainings].reverse_each do |p|
        #  @post = Post.find(p[1])
        #  @post.touch
        #end
        #redirect_to trainings_url
      end
      
      def detail
        post = Post.where(:id => params[:id]).includes(:likes, :flags, :comments => [:likes, :flags]).first
        if post
          begin
            #UserAnalytic.create(:action => 2,:org_id => post[:org_id], :user_id => params[:user_id], :source_id => params[:id], :ip_address => request.remote_ip.to_s)
            ##UserAnalytic.create(:action => 2,:org_id => post[:org_id], :user_id => params[:user_id], :ip_address => request.remote_ip.to_s)
          rescue
          end
          #  Notification.did_view(params[:user_id], 4, params[:id])
          if !params[:silent].present?
            Notification.did_view(params[:user_id], 4, params[:id]) unless params[:reset_count].present?
            post.add_view
          end

          post.check_user(params[:user_id])

          post.comments.each do |p|
            p.check_user(params[:user_id])
          end
          if PostType.find_post_type(post[:post_type]) == "post"
            render json: post, serializer: PostDetailSerializer
          elsif PostType.find_post_type(post[:post_type]) == "announcement"
            render json: post, serializer: AnnouncementDetailSerializer
          else
            render json: post, serializer: PostDetailSerializer
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Cannot find post" } }
        end
      end
      
      def like
        post = Post.find(params[:id])
        push = params[:dont_push].present? ? false : true
        @like = Like.new(
          :owner_id => params[:user_id],
          :source => Source.id_from_name(PostType.find_post_type(post[:post_type])),
          :source_id => params[:id]
        )
        @like.create_like("post", post, push)

        #Mession.broadcast(post[:org_id], "refresh", "notification", 4, post[:id], params[:user_id], post[:owner_id])
        render json: @like, serializer: LikeSerializer
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

      def swap_sorted_dates
        if Post.exists?(:id => params[:first_id]) and Post.exists?(:id => params[:second_id])
          @first_post = Post.find_by_id(params[:first_id])
          @second_post = Post.find_by_id(params[:second_id])

          Rails.logger.debug("first post id: #{@first_post.id}")
          Rails.logger.debug("second post id: #{@second_post.id}")
          Rails.logger.debug("first post sorted_at: #{@first_post.sorted_at}")
          Rails.logger.debug("second post sorted_at: #{@second_post.sorted_at}")
          
          # swap the values for first post's and second post's 'sorted_at'
          tmp = "#{@first_post.sorted_at}"
          @first_post.sorted_at = "#{@second_post.sorted_at}"
          @second_post.sorted_at = tmp

          # save the swap to the database
          if @first_post.save and @second_post.save
            render json: { "eXpresso" => { "code" => 1, "message" => "Post sorted_at date update success." } }
          else
            render json: { "eXpresso" => { "code" => -131, "message" => "Post sorted_at date update failed." } }
          end
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
