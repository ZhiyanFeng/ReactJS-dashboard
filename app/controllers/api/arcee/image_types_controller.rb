module Api
  module Arcee
    class ImageTypesController < ApplicationController
      
      before_filter :set_headers
      
      respond_to :json

      def index
        respond_with ImageType.all
      end

      def show
        respond_with ImageType.find(params[:id])
      end

      def create
        token = SecureRandom.hex
        @imagetype = ImageType.new(:access_token => token, :app_platform => params[:platform])
        @imagetype.save
        
        respond_to do |format|
          format.html { render json: @imagetype, status: 200 }
          format.json { render json: @imagetype, status: 200 }
        end
      end

      def update
        respond_with ImageType.update(params[:id], params[:user])
      end

      def destroy
        respond_with ImageType.update(params[:id], {:is_valid => false})
      end
      
    end
  end
end