include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class LikesController < ApplicationController
      
      before_filter :restrict_access, :set_headers
      
      respond_to :json

      def index
        respond_with Like.all
      end

      def show
        respond_with Like.find(params[:id])
      end

      def create
        @like = Like.new(params[:like])
        
        respond_to do |format|
          if @like.save
            format.html { render json: @like, status: 200 }
            format.json { render json: @like, status: 200 }
          else
            format.html { render json: @like.errors, status: 422 }
            format.json { render json: @like.errors, status: 422 }
          end
        end
      end

      #def update
      #  respond_with Like.update(params[:id], params[:user])
      #end

      def destroy
        respond_with Like.update(params[:id], {:is_valid => false})
      end
    end
  end
end