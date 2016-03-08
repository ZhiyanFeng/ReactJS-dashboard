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

      before_filter :restrict_access, :set_headers

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

    end
  end
end
