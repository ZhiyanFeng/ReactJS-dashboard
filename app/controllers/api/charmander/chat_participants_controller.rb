include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class ChatParticipantsController < ApplicationController
      
      before_filter :restrict_access, :set_headers
      
      respond_to :json

      def index
        respond_with ChatParticipant.all
      end

      def show
        respond_with ChatParticipant.find(params[:id])
      end
      
      def reset
        @chatparticipant = ChatParticipant.find(params[:id])
        if @chatparticipant.reset_count        
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -304, "message" => "Reset failed" } }
        end
      end

      def create
        @chatparticipant = ChatParticipant.new(params[:chatparticipant])
        
        respond_to do |format|
          if @chatparticipant.save
            format.html { render json: @chatparticipant, status: 200 }
            format.json { render json: @chatparticipant, status: 200 }
          else
            format.html { render json: @chatparticipant.errors, status: 422 }
            format.json { render json: @chatparticipant.errors, status: 422 }
          end
        end
      end

      #def update
      #  respond_with ChatParticipant.update(params[:id], params[:user])
      #end

      def destroy
        @chatparticipant = ChatParticipant.find(params[:id])

        if @chatparticipant.update_attribute(:is_active, false)        
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -305, "message" => "Delete failed" } }
        end
      end      
    end
  end
end