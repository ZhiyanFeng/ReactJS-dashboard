include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
    class UserPrivilegesController < ApplicationController
      class UserPrivilege < ::UserPrivilege
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :set_headers
      
      respond_to :json

      def fix_existing_subscriptions
        count = 0
        UserPrivilege.where(:location_id => 0).each do |key|
          if Location.exists?(:org_id => key[:org_id])
            @location = Location.where(:org_id => key[:org_id]).first
            if User.exists?(:id => key[:owner_id])
              user = User.find(key[:owner_id])
              user.update_attribute(:location, @location[:id])
              if user[:location].present? && user[:location] != 0
                if key.update_attribute(:location_id, user[:location])
                  count = count + 1
                end
              end
            end
          end
        end

        render json: { "eXpresso" => { "code" => 1, "message" => "#{count} records updated" } }
      end

    end
  end
end