include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Ditto
    class NotificationsController < ApplicationController
      class Notification < ::Notification
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access#, :except => []
      before_filter :validate_session#, :except => []
      before_filter :set_headers

      respond_to :json

      def destroy
        if Notification.exists?(:id => params[:id])
          @notifcation = Notification.find(params[:id])
          @notifcation.update_attribute(:is_valid => false)
          render json: @notifcation, serializer: SyncNotificationSerializer
        else
          render :json => { "eXpresso" => { "code" => -1, "error" => I18n.t('warning.error.notification.does_not_exist') } }
        end
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
