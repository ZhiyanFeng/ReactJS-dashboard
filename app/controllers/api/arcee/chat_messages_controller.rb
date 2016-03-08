include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class ChatMessagesController < ApplicationController
      
      before_filter :restrict_access, :set_headers
      
      respond_to :json

      def index
        respond_with ChatMessage.all
      end

      def show
        respond_with ChatMessage.find(params[:id])
      end

      def create
        @chatmessage = ChatMessage.new(params[:chatmessage])
        
        respond_to do |format|
          if @chatmessage.save
            format.html { render json: @chatmessage, status: 200 }
            format.json { render json: @chatmessage, status: 200 }
          else
            format.html { render json: @chatmessage.errors, status: 422 }
            format.json { render json: @chatmessage.errors, status: 422 }
          end
        end
      end

      #def update
      #  respond_with ChatMessage.update(params[:id], params[:user])
      #end

      def destroy
        respond_with ChatMessage.update(params[:id], {:is_valid => false})
      end      
    end
  end
end