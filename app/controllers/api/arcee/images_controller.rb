include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class ImagesController < ApplicationController
      class Image < ::Image
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :set_headers, :except => [:drop_image, :drop_profile]

      respond_to :json

      def index
        @images = Image.all
        render json: @images, each_serializer: ImageSerializer
      end

      def detail
        image = Image.find(params[:id])
        image.check_user(params[:user_id])
        if image.comments.presence
          image.comments.each do |p|
            p.check_user(params[:user_id])
          end
        end
        render json: image, serializer: ImageDetailSerializer
      end

      def create
        @image = Image.new(params[:image])
        @image.save
        respond_to do |format|
          format.html { render json: @image, serializer: ImageSerializer }
          format.json { render json: @image, serializer: ImageSerializer }
        end
      end

      #def update
      #  @image = Image.find(params[:id])
      #  if @image.update(params[:image])
      #    render :json => @image, serializer: ImageSerializer
      #  else
      #    render :json => @image.errors
      #  end
      #end

      def comment
        image = Image.find(params[:id])
        @comment = Comment.new(
          :content => params[:content],
          :owner_id => params[:user_id],
          :source => 3,
          :source_id => image[:id]
        )
        if @comment.create_comment("image", image)
          image.update_attribute(:comments_count, image.comments_count + 1)
          render json: @comment, serializer: CommentSerializer
        else
          render json: @comment.errors
        end
      end

      def like
        image = Image.find(params[:id])
        @like = Like.new(
          :owner_id => params[:user_id],
          :source => Source.id_from_name("image"),
          :source_id => params[:id]
        )
        @like.create_like("image", image)

        render json: @like, serializer: LikeSerializer
      end

      def unlike
        image = Image.find(params[:id])
        if Like.exists?(:owner_id => params[:user_id], :source => 3, :source_id => params[:id], :is_valid => true)
          @like = Like.where(:owner_id => params[:user_id], :source => 3, :source_id => params[:id], :is_valid => true).last
          @like.destroy_like

          render json: @like, serializer: LikeSerializer
        else
          render json: "-1001: Operation could not be completed. Object does not exist.", status: 422
        end
      end

      def flag
        image = Image.find(params[:id])
        @flag = Flag.new(
          :owner_id => params[:user_id],
          :source => Source.id_from_name("image"),
          :source_id => params[:id]
        )
        @flag.create_flag(params[:id])

        render json: @flag, serializer: FlagSerializer
      end

      def destroy
        if Image.exists?(:id => params[:id])
          @image = Image.find(params[:id])
          if @image.update(:is_valid => false)
            render :json => { "response" => "success" }
          else
            render :json => @image.errors
          end
        end
      end

      def drop_image
        @image = Image.new(params[:image])
        if @image.save
          if @image.create_and_upload_post_image(params[:file])
            if params[:image][:is_valid]
              @image.update_attributes(:is_valid => params[:image][:is_valid])
            else
              @image.update_attributes(:is_valid => true)
            end
            #@organization = Organization.find_by_id(1)
            #if @organization.update_attributes(:profile_id => @image[:id])
            temp = '{"objects":[{"source":3, "source_id":' + @image.id.to_s + '}]}'
            @attachment = Attachment.new(
              :json => temp
            )
            @attachment.save
            render json: @attachment.id, status: :created
          end
        else
          Rails.logger.debug(@image.errors.inspect)
          render json: @image.errors, status: :unprocessable_entity
        end
      end

      def drop_profile
        @image = Image.new(:org_id => 1, :owner_id => params[:owner_id])

        if is_equal_to(params[:reference], "org_profile")
          if @image.create_upload_and_set_organization_profile(1, params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        end
      end

      def upload_image
        @image = Image.new(:org_id => 1, :owner_id => params[:owner_id])

        if is_equal_to(params[:reference], "user_profile")
          if @image.create_upload_and_set_user_profile(params[:owner_id], params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        elsif is_equal_to(params[:reference], "user_cover")
          if @image.create_and_upload_user_cover_image(params[:owner_id], params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        elsif is_equal_to(params[:reference], "channel_profile")
          if @image.create_upload_and_set_channel_profile(params[:owner_id], params[:file], params[:channel_id])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        elsif is_equal_to(params[:reference], "org_profile")
          if @image.create_upload_and_set_organization_profile(1, params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        elsif is_equal_to(params[:reference], "org_cover")
          if @image.create_and_upload_organization_cover_image(1, params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        elsif is_equal_to(params[:reference], "org_profile_android")
          if @image.create_upload_and_set_organization_profile_android(params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        elsif is_equal_to(params[:reference], "user_gallery")
          if @image.create_and_upload_user_gallery_image(params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        elsif is_equal_to(params[:reference], "org_gallery")
          if @image.create_and_upload_org_gallery_image(params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        elsif is_equal_to(params[:reference], "newsfeed")
          if @image.create_and_upload_org_gallery_image(params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        elsif is_equal_to(params[:reference], "announcement")
          if @image.create_and_upload_org_gallery_image(params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        else
          if @image.create_and_upload(params[:file])
            render json: @image, serializer: ImageSerializer
          else
            render json: @image.errors
          end
        end
        Follower.follow(3, @image[:id], params[:owner_id])
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
