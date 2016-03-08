include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class NotificationsController < ApplicationController
      
      before_filter :restrict_access, :set_headers
      #before_filter :validate_session
      
      respond_to :json

      def index
        respond_with Notification.all
      end

      def show
        respond_with Notification.find(params[:id])
      end

      def create
        @notification = Notification.new(params[:notification])
        
        respond_to do |format|
          if @notification.save
            format.html { render json: @notification, status: 200 }
            format.json { render json: @notification, status: 200 }
          else
            format.html { render json: @notification.errors, status: 422 }
            format.json { render json: @notification.errors, status: 422 }
          end
        end
      end
      
      def viewed
        if Notification.exists?(:id => params[:id])
          @notification = Notification.find(params[:id])
          if @notification.update(:viewed => true)
            render :json => { "response" => "success" }
          else
            render :json => @notification.errors
          end
        end
      end

      def viewed_all
        if Notification.where(:notify_id => params[:user_id]).update_all(:viewed => true)
          render json: { "eXpresso" => { "code" => 1, "message" => "Success." } }
        else
          render json: { "eXpresso" => { "code" => -156, "message" => "Operation failed." } }
        end
      end

      #def update
      #  respond_with Notification.update(params[:id], params[:user])
      #end

      def destroy
        respond_with Notification.update(params[:id], {:is_valid => false})
      end      
    end
  end
end