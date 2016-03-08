include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class FollowersController < ApplicationController
      
      before_filter :restrict_access, :set_headers
      
      respond_to :json

      def index
        respond_with Follower.all
      end

      def show
        respond_with Follower.find(params[:id])
      end

      def create
        @follower = Follower.new(params[:follower])
        
        respond_to do |format|
          if @follower.save
            render :json => { "code" => 1 }
          else
            render :json => { "code" => -900 }
          end
        end
      end

      #def update
      #  respond_with Follower.update(params[:id], params[:user])
      #end

      def destroy
        respond_with Follower.update(params[:id], {:is_valid => false})
      end      
    end
  end
end