include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
    class ImagesController < ApplicationController
      class Image < ::Image
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :set_headers, :except => [:process_image]

      respond_to :json

      def process_image
        @user = User.find(params[:user_id])
        @image = Image.new(
          :org_id => 1,
          :owner_id => @user[:id],
          :image_type => Image.reference_by_description(params[:image_type])
        )
        @image.avatar_remote_url = params[:remote_image_url]
        if @image.save
          temp = '{"objects":[{"source":3, "source_id":' + @image.id.to_s + '}]}'
          @attachment = Attachment.new(:json => temp)
          if @attachment.save
            render json: @attachment.id, status: :created
          else
            render json: { "eXpresso" => { "code" => -1, "message" => @attachment.errors } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => @image.errors } }
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
