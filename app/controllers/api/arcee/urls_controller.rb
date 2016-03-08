include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class UrlsController < ApplicationController
      class Url < ::Video
        # Note: this does not take into consideration the create/update actions for changing released_on
    
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end
  
      def index
        @urls = Url.all
        render json: @urls, each_serializer: UrlSerializer
      end

      def show
        @url = Url.find(params[:id])
        render json: @url, serializer: UrlSerializer
      end

      def update
        @url = Url.find(params[:id])
        if @url.update!(params[:video])
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -185, "message" => @url.errors } }
        end
      end
  
    end
  end
end
