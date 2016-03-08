module Api
  module Bumblebee
    class PostTypesController < ApplicationController
      
      before_filter :set_headers
      
      respond_to :json

      def index
        respond_with PostType.all
      end

      def show
        respond_with PostType.find(params[:id])
      end

      def create
        token = SecureRandom.hex
        @posttype = PostType.new(:access_token => token, :app_platform => params[:platform])
        @posttype.save
        
        respond_to do |format|
          format.html { render json: @posttype, status: 200 }
          format.json { render json: @posttype, status: 200 }
        end
      end

      def update
        respond_with PostType.update(params[:id], params[:user])
      end

      def destroy
        respond_with PostType.update(params[:id], {:is_valid => false})
      end      
    end
  end
end